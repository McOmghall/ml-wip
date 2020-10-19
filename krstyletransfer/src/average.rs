use std::{path, path::Path};
use image::{*};
use log::*;
use imageproc::*;
use walkdir::{WalkDir};
use rayon::prelude::*;

#[derive(Clone)]
struct ImageData {
    image : DynamicImage,
    path : path::PathBuf,
}

pub fn average_all_images(startup_path: &Path) {
    let images: Vec<DynamicImage> = WalkDir::new(startup_path)
            .follow_links(false)
            .contents_first(true)
            .into_iter()
            .filter_map(|maybe_entry| maybe_entry.ok())
            .filter_map(|entry| {
                image::open(entry.path()).and_then(|image | {
                    let resolution = image.dimensions();
                    info!(target: "kr_style_transfer", "Loaded Image type {:?}:{:?} at {:?}", entry.path().extension().expect("unk"), resolution, entry.path());
                    Ok(image)
                }).ok()
            }).collect();

    let bounds = images[0].dimensions();
    let count = images.len();

    info!(target: "kr_style_transfer", "Running over {:?} images", count);
    let mut inner = images.clone();
    const chunk_size: i32 = 4;
    loop  {
        let innerproc = inner.par_chunks_exact(chunk_size as usize);
        let mut processing_images: Vec<DynamicImage> = Vec::new();
        processing_images.append(innerproc.remainder().to_vec().as_mut());

        processing_images.par_extend(innerproc.map(|a| {
            let img1 = a[0].clone().resize_exact(bounds.0, bounds.1, imageops::FilterType::Gaussian);
            let img2 = a[1].clone().resize_exact(bounds.0, bounds.1, imageops::FilterType::Gaussian);
            let img3 = a[2].clone().resize_exact(bounds.0, bounds.1, imageops::FilterType::Gaussian);
            let img4 = a[3].clone().resize_exact(bounds.0, bounds.1, imageops::FilterType::Gaussian);
            let subimg1 = DynamicImage::ImageRgba8(map::map_colors2(&img1, &img2, |a, b| {
                let r = a.map2(&b, |ca, cb| { ((ca as f32 + cb as f32) / 2 as f32).round() as u8  });
                r
            }));
            let subimg2 = DynamicImage::ImageRgba8(map::map_colors2(&img3, &img4, |a, b| {
                let r = a.map2(&b, |ca, cb| { ((ca as f32 + cb as f32) / 2 as f32).round() as u8  });
                r
            }));
            let subimgfinal = DynamicImage::ImageRgba8(map::map_colors2(&subimg1, &subimg2, |a, b| {
                let r = a.map2(&b, |ca, cb| { ((ca as f32 + cb as f32) / 2 as f32).round() as u8  });
                r
            }));
            subimgfinal
        }));

        if processing_images.len() == 1 {
            processing_images.first().expect("WOT").save_with_format(format!("./test-{}.png", "true"), ImageFormat::Png);
            break;
        }
        info!(target: "kr_style_transfer", "Processing {:?} images, {:?} remain", count, processing_images.len());
        inner = processing_images;
    }
}


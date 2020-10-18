use std::{path, path::Path};
use image::{*};
use log::*;
use imageproc::*;
use walkdir::{WalkDir};

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
    loop  {
        let innerproc = &inner.chunks_exact(2);
        let mut processing_images: Vec<DynamicImage> = innerproc.clone().map(|a| {
                let img1 = a[0].clone().resize_exact(bounds.0, bounds.1, imageops::FilterType::Gaussian);
                let img2 = a[1].clone().resize_exact(bounds.0, bounds.1, imageops::FilterType::Gaussian);
                DynamicImage::ImageRgba8(map::map_colors2(&img1, &img2, |a, b| {
                    let r = a.map2(&b, |ca, cb| { ((ca as f32 + cb as f32) / 2 as f32).round() as u8  });
                    r
                }))
            }).collect();
            
        if innerproc.remainder().len() > 0 {
            processing_images.push(innerproc.remainder()[0].clone())
        };

        if processing_images.len() == 1 {
            processing_images.first().expect("WOT").save_with_format(format!("./test-{}.png", "true"), ImageFormat::Png);
            break;
        }
        info!(target: "kr_style_transfer", "Processing {:?} images, {:?} remain", count, processing_images.len());
        inner = processing_images;
    }
}


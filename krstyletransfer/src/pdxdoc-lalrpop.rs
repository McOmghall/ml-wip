use lalrpop;

fn main() {
    lalrpop::Configuration::new()
        .always_use_colors()
        //.emit_comments(true)
        .force_build(true)
        .unit_test()
        .log_debug()
        .process_current_dir()
        .unwrap();
}

/* NOTHING BELOW HERE
// CUSTOM LEXER
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum PDXToken<'input> {
    // Sigils
    NewLine,
    OpenBrace,
    CloseBrace,
    Equal,

    // Literals
    Identifier(&'input str),
    String(&'input str),
    Number(Decimal),
}

pub enum PDXTokenId {
    // Sigils
    NewLine,
    OpenBrace,
    CloseBrace,
    Equal,

    // Literals
    Identifier,
    String,
    Number,

}

static NEWLINE_SUB: &'static str = r"\n";
static SKIPPABLE: &'static [char] = &[' ', ';'];

pub struct Lexer<'input> {
    chars: CharIndices<'input>,
}

impl<'input> Lexer<'input> {
    pub fn new(input: &'input str) -> Self { // Strip comments regex
        Lexer { chars: input.char_indices() }
    }
}
pub type Spanned<T> = (usize, T, usize);
impl<'input> Iterator for Lexer<'input> {
    type Item = Spanned<PDXToken<'input>>;

    fn next(&mut self) -> Option<Self::Item> {
        let str = self.chars.as_str();
        let type_map = [
            (Regex::new(r"?m\A#.*$").unwrap(), None),
            (Regex::new(r"\A(\n | \r | \n\r)").unwrap(), Some(PDXTokenId::NewLine)),
            (Regex::new(r"\A{").unwrap(), Some(PDXTokenId::OpenBrace)),
            (Regex::new(r"\A}").unwrap(), Some(PDXTokenId::CloseBrace)),
            (Regex::new(r"\A=").unwrap(), Some(PDXTokenId::Equal)),
        ];

        self.chars.next().and_then(|ch| {
            for (r, m) in type_map.iter() {
                match r.shortest_match(str) {
                    Some(a) => {
                        match m {
                            Some(PDXTokenId::NewLine) => return Some((ch.0, PDXToken::NewLine, a)),
                            Some(PDXTokenId::OpenBrace) => return Some((ch.0, PDXToken::OpenBrace, a)),
                            Some(PDXTokenId::CloseBrace) => return Some((ch.0, PDXToken::CloseBrace, a)),
                            Some(PDXTokenId::Equal) => return Some((ch.0, PDXToken::Equal, a)),
                            _ => continue,
                        }
                    }
                    _ => continue,
                }
            }
            None
        })
    }
}
*/
use image::{self};
use rustler::{Binary, Env, NifResult};

#[rustler::nif]
fn to_grayscale<'a>(env: Env<'a>, input: Binary<'a>) -> NifResult<Binary<'a>> {
    let reader = image::io::Reader::new(std::io::Cursor::new(&*input))
        .with_guessed_format()
        .unwrap();
    let mut image = reader.decode().unwrap();

    image = image.grayscale();

    let mut out = rustler::types::NewBinary::new(env, image.as_bytes().len());

    image
        .write_to(
            &mut std::io::BufWriter::new(std::io::Cursor::new(out.as_mut_slice())),
            image::ImageOutputFormat::Jpeg(100),
        )
        .unwrap();

    // image::ImageOutputFormat::Png,

    Ok(out.into())

    // Ok(output.release(env))
}

rustler::init!("Elixir.ImageNif");

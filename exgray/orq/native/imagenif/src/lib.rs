use rustler::{Binary, Env, NifResult, OwnedBinary};

#[rustler::nif]
fn to_grayscale<'a>(env: Env<'a>, input: Binary<'a>) -> NifResult<Binary<'a>> {
    let img = image::load_from_memory(&input).unwrap().to_luma8();
    let mut output = OwnedBinary::new(img.len()).unwrap();
    output.as_mut_slice().copy_from_slice(&img);
    Ok(output.release(env))
}

rustler::init!("Elixir.ImageNif");


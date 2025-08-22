import gleam/bool
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/erlang/atom.{type Atom}
import gleam/result

import gleam/int
import gleam/string

pub type Image {
  Image
  Nil
}

pub type ImageFormat {
  JPEG(quality: Int, keep_metadata: Bool)
}

pub type FormatComponents {
  FormatComponents(extension: String, format: String)
}

fn image_format_to_string(format: ImageFormat) -> FormatComponents {
  case format {
    JPEG(quality:, keep_metadata:) ->
      FormatComponents(".jpg", format_common_options(quality, keep_metadata))
  }
}

fn format_common_options(quality, keep_metadata) {
  "[Q="
  <> int.to_string(quality)
  <> ",strip="
  <> bool.to_string(!keep_metadata) |> string.lowercase
  <> "]"
}

pub fn read(from path: String) -> Result(Image, String) {
  new_from_file(path)
}

pub fn write(
  image: Image,
  to path: String,
  using format: ImageFormat,
) -> Result(String, String) {
  let FormatComponents(extension, options) = image_format_to_string(format)
  let res = write_to_file(image, path <> extension <> options)
  // This works because successful write returns the atom :ok
  case decode.run(res, atom.decoder()) {
    Ok(_) -> Ok(path <> extension)
    // Let's decode the original error
    _ -> {
      echo res
      Error("Could not write image: " <> path <> extension)
    }
  }
}

pub fn grayscale(img: Image) -> Result(Image, String) {
  colourspace(img, atom.create("VIPS_INTERPRETATION_B_W"))
}

pub fn sepia(image: Image) -> Result(Image, String) {
  use gray <- result.try(colourspace(
    image,
    atom.create("VIPS_INTERPRETATION_B_W"),
  ))
  use gray_rgb <- result.try(colourspace(
    gray,
    atom.create("VIPS_INTERPRETATION_sRGB"),
  ))
  let sepia_values = [
    // Output Red = 0.393*R + 0.769*G + 0.189*B
    [0.393, 0.769, 0.189],
    // Output Green = ...
    [0.349, 0.686, 0.168],
    // Output Blue = ...
    [0.272, 0.534, 0.131],
  ]
  use sepia_matrix_img <- result.try(new_matrix_from_array(3, 3, sepia_values))
  recomb(gray_rgb, sepia_matrix_img)
}

// region:    --- FFI
@external(erlang, "Elixir.Vix.Vips.Operation", "colourspace")
fn colourspace(image: Image, interpretation: Atom) -> Result(Image, String)

@external(erlang, "Elixir.Vix.Vips.Operation", "gaussblur")
pub fn gaussblur(image: Image, sigma: Float) -> Result(Image, String)

@external(erlang, "Elixir.Vix.Vips.Image", "new_from_file")
fn new_from_file(from path: String) -> Result(Image, String)

// Making Dynamic because the function returns Ok or Error(String):w
// @spec write_to_file(t(), String.t(), keyword()) :: :ok | {:error, term()}
@external(erlang, "Elixir.Vix.Vips.Image", "write_to_file")
fn write_to_file(image: Image, to save_path_options: String) -> Dynamic

@external(erlang, "Elixir.Vix.Vips.Image", "new_matrix_from_array")
fn new_matrix_from_array(
  witdh: Int,
  height: Int,
  list: List(List(Float)),
) -> Result(Image, String)

@external(erlang, "Elixir.Vix.Vips.Operation", "recomb")
fn recomb(image: Image, matix: Image) -> Result(Image, String)
// endregion: --- FFI

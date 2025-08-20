import eil.{type Image}
import gleam/bool
import gleam/int
import gleam/string

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
  read_ffi(path)
}

@external(erlang, "Elixir.Eil", "read")
fn read_ffi(from path: String) -> Result(Image, String)

pub fn write(
  image: Image,
  to path: String,
  using format: ImageFormat,
) -> Result(String, String) {
  write_ffi(image, path, image_format_to_string(format))
}

@external(erlang, "Elixir.Eil", "write_to_file")
fn write_ffi(
  image: Image,
  to path: String,
  using format: FormatComponents,
) -> Result(String, String)

pub fn grayscale(img: Image) -> Result(Image, String) {
  grayscale_ffi(img)
}

@external(erlang, "Elixir.Eil", "grayscale")
fn grayscale_ffi(image: Image) -> Result(Image, String)

pub fn gaussblur(img: Image, sigma: Float) -> Result(Image, String) {
  gaussblur_ffi(img, sigma)
}

@external(erlang, "Elixir.Eil", "gaussblur")
fn gaussblur_ffi(image: Image, sigma: Float) -> Result(Image, String)

pub fn sepia(img: Image) -> Result(Image, String) {
  sepia_ffi(img)
}

@external(erlang, "Elixir.Eil", "sepia")
fn sepia_ffi(image: Image) -> Result(Image, String)

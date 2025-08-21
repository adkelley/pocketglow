import gleam/io
import gleam/result
import gleam/string
import image.{type Image}
import pocketflow.{type Node, Node, Params, max_retries, wait}
import simplifile
import types.{
  type Filtered, type Loaded, type Saved, type Shared, type Start, Blur,
  Filtered, Grayscale, Loaded, Saved, Sepia, Shared, Start,
}

pub fn load_image(node: Node(Start, Shared)) -> Node(Loaded, Shared) {
  pocketflow.basic_node(
    prep: {
      let Node(Start, shared) = node
      Params("./images/" <> shared.input, max_retries, wait)
    },
    exec: fn(image_path: String) { image.read(image_path) },
    post: fn(image: Result(Image, String)) {
      let assert Ok(image) = image
      io.println("loaded_image")
      let Node(Start, shared) = node
      Node(Loaded, Shared(..shared, image: image))
    },
  )
}

pub fn apply_filter(node: Node(Loaded, Shared)) -> Node(Filtered, Shared) {
  pocketflow.basic_node(
    prep: {
      let Node(Loaded, shared) = node
      Params(shared.image, max_retries, wait)
    },
    exec: fn(image: Image) {
      let Node(Loaded, shared) = node
      case shared.filter {
        Grayscale -> image.grayscale(image)
        Blur -> image.gaussblur(image, 3.0)
        Sepia -> image.sepia(image)
      }
    },
    post: fn(filtered_image: Result(Image, String)) {
      let assert Ok(image) = filtered_image
      io.println("apply_filter")
      let Node(Loaded, shared) = node
      Node(Filtered, Shared(..shared, image: image))
    },
  )
}

pub fn save_image(node: Node(Filtered, Shared)) -> Node(Saved, Shared) {
  pocketflow.basic_node(
    prep: {
      // create the directory if it doesn't already exist
      let _ = simplifile.create_directory("output")
      // Generate output filename
      let Node(Filtered, shared) = node
      let #(input_name, _) =
        shared.input
        |> string.split_once(on: ".")
        |> result.unwrap(#("image", ""))
      let filter_name = case shared.filter {
        Grayscale -> "grayscale"
        Blur -> "blur"
        Sepia -> "sepia"
      }
      Params(
        string.concat(["./output/", input_name, "_", filter_name]),
        max_retries,
        wait,
      )
    },
    exec: fn(image_path: String) {
      let Node(Filtered, shared) = node
      image.write(
        shared.image,
        image_path,
        using: image.JPEG(quality: 100, keep_metadata: False),
      )
    },
    post: fn(exec_res: Result(String, String)) {
      let assert Ok(output_path) = exec_res
      io.println("Saved filtered image to: " <> output_path)
      let Node(Filtered, shared) = node
      Node(Saved, shared)
    },
  )
}

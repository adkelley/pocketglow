defmodule Eil do
  alias Vix.Vips.{Image, Operation}

  def read(path) do
    Path.expand(path) |> Image.new_from_file()
  end

  def write_to_file(img, path, {:format_components, extension, options}) do
    save_path = Path.expand(path <> extension)
    case Image.write_to_file(img, save_path <> options) do
      :ok -> {:ok, save_path}
      {:error, reason} -> {:error, reason}
    end
  end

  # Image -> Result(Image, String)
  def grayscale(image) do
    Operation.colourspace(image, :VIPS_INTERPRETATION_B_W) 
  end

  # Image -> Float -> Result(Image, String)
  def gaussblur(image, sigma) do
    Operation.gaussblur(image, sigma)
  end

  def sepia(image) do
    # 1. Convert to grayscale
    {:ok, gray} = Operation.colourspace(image, :VIPS_INTERPRETATION_B_W)

    # 2. Convert grayscale to sRGB (so we can apply RGB matrix)
    # Make three copies of the grayscale band and join them
    {:ok, gray_rgb} = Operation.colourspace(gray, :VIPS_INTERPRETATION_sRGB)

    # 3. Apply the sepia 'linear' color matrix
    #    Each output channel = a*R + b*G + c*B; using common sepia coefficients
    sepia_values = [
      [0.393, 0.769, 0.189],  # Output Red = 0.393*R + 0.769*G + 0.189*B
      [0.349, 0.686, 0.168],  # Output Green = ...
      [0.272, 0.534, 0.131]   # Output Blue = ...
    ]
    {:ok, sepia_matrix_img} = Image.new_matrix_from_array(3, 3, sepia_values)

    Operation.recomb(gray_rgb, sepia_matrix_img)
  end
end

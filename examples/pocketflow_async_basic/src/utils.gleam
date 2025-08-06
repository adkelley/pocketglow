import gleam/erlang/process
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import input
import task

pub fn fetch_recipes(ingredient) -> List(String) {
  let recipes = [
    ingredient <> " Stir Fry",
    "Grilled " <> ingredient <> " with Herbs",
    "Baked " <> ingredient <> " with Vegetables",
  ]
  let recipes_len = list.length(recipes) |> int.to_string

  // Simulate API call with delay
  let handle = task.async(fn() { process.sleep(500) })
  io.println("Fetching recipes for " <> ingredient)
  task.await(handle, 1000)

  io.println("Found " <> recipes_len <> " recipes")
  recipes
}

pub fn get_user_input(prompt: String) -> String {
  let assert Ok(answer) = input.input(prompt)
  answer
}

pub fn call_llm_async(prompt: String) -> String {
  // Mock LLM Call
  let recipes = string.split(prompt, on: ", ")
  let assert Ok(suggestion) = list.last(recipes)
  // Simulate LLM call with delay
  io.println("Suggesting best recipe ...")
  let handle = task.async(fn() { process.sleep(100) })
  task.await(handle, 500)
  io.println("How about: " <> suggestion <> " ?")
  suggestion
}

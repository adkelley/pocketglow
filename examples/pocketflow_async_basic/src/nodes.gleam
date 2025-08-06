import gleam/io
import gleam/string
import pocketflow.{type Shared, Fsm, Shared}
import task
import types.{type Values, Accept, Approve, Retry, Suggest, Values}
import utils

pub fn fetch_recipes(shared: Shared(Values)) {
  pocketflow.basic_node(
    prep: {
      let handle =
        task.async(fn() { utils.get_user_input("Enter ingredient: ") })
      let Shared(values) = shared
      Values(..values, ingredient: task.await(handle, 10_000))
    },
    exec: fn(values: Values) {
      let handle = task.async(fn() { utils.fetch_recipes(values.ingredient) })
      Values(..values, recipes: task.await(handle, 5000))
    },
    post: fn(values: Values) { Fsm(Shared(values), Suggest) },
  )
}

pub fn suggest_recipe(shared: Shared(Values)) {
  pocketflow.basic_node(
    prep: {
      let Shared(values) = shared
      values
    },
    exec: fn(values: Values) {
      let handle =
        task.async(fn() {
          utils.call_llm_async(string.join(values.recipes, ", "))
        })
      Values(..values, suggestion: task.await(handle, 5000))
    },
    post: fn(values: Values) { Fsm(Shared(values), Approve) },
  )
}

pub fn get_approval(shared: Shared(Values)) {
  pocketflow.basic_node(
    prep: { Nil },
    exec: fn(_) {
      let handle =
        task.async(fn() { utils.get_user_input("\nAccept this recipe? (y/n) ") })
      task.await(handle, 5000)
    },
    post: fn(answer: String) {
      let Shared(values) = shared
      case answer {
        "y" -> {
          io.println("\nGreat choice! Here's your recipe...")
          io.println("Recipe: " <> values.suggestion)
          io.println("Ingredient: " <> values.ingredient)
          Fsm(shared, Accept)
        }
        _ -> {
          io.println("\nLet's try another recipe...")
          Fsm(shared, Retry)
        }
      }
    },
  )
}

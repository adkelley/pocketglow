import gleam/dict
import gleam/int
import gleam/list
import pocketflow.{type Shared}
import shared_type.{type Values, Statistics, Values}

type Sales {
  Sales(total_sales: Int, num_transactions: Int, total_amount: Int)
}

pub fn csv_processer(shared: Shared(Values)) -> Shared(Values) {
  pocketflow.batch_node(
    prep: {
      let chunks = [[1, 2, 3, 4, 5], [1, 2, 3, 4, 5]]
      chunks
    },
    exec: fn(chunk: List(Int)) {
      Sales(
        num_transactions: list.length(chunk),
        total_sales: list.fold(chunk, 0, fn(acc, x) { acc + x }),
        total_amount: list.fold(chunk, 0, fn(acc, x) { acc + x }),
      )
    },
    post: fn(exec_res: List(Sales)) {
      let assert Ok(post_res) = dict.get(shared, "prep_res")

      let #(total_transactions, total_sales) =
        list.fold(exec_res, #(0, 0), fn(acc, sales) {
          #(acc.0 + sales.num_transactions, acc.1 + sales.total_sales)
        })
      let average_sale =
        int.to_float(total_sales) /. int.to_float(total_transactions)
      //  Store the final article in shared datao
      let post_res =
        Values(
          post_res.input_file,
          post_res.chunk_size,
          Statistics(total_sales, total_transactions, average_sale),
        )

      dict.insert(shared, "post_res", post_res)
    },
  )
}

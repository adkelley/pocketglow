import gleam/int
import gleam/io
import gleam/list
import gleam/result
import pocketglow.{type Node, Node, Params, max_retries, wait}
import types.{
  type Processed, type Shared, type Start, Processed, Shared, Start, Statistics,
}

type Sales {
  Sales(total_sales: Int, num_transactions: Int, total_amount: Int)
}

pub fn csv_processer(processor: Node(Start, Shared)) -> Node(Processed, Shared) {
  pocketglow.batch_node(
    prep: {
      let chunks = [[1, 2, 3, 4, 5], [1, 2, 3, 4, 5]]
      Params(chunks, max_retries, wait)
    },
    exec: fn(chunk: List(Int)) {
      Sales(
        num_transactions: list.length(chunk),
        total_sales: list.fold(chunk, 0, fn(acc, sale) { acc + sale }),
        total_amount: list.fold(chunk, 0, fn(acc, amount) { acc + amount }),
      )
      |> Ok()
    },
    post: fn(exec_res: List(Result(Sales, String))) {
      let partition = result.partition(exec_res)
      case partition.1 {
        [] -> {
          let #(total_transactions, total_sales) =
            list.fold(partition.0, #(0, 0), fn(acc, sales) {
              #(acc.0 + sales.num_transactions, acc.1 + sales.total_sales)
            })
          let average_sale =
            int.to_float(total_sales) /. int.to_float(total_transactions)
          //  Store the final article in shared datao
          let Node(Start, shared) = processor
          Node(
            Processed,
            Shared(
              ..shared,
              statistics: Statistics(
                total_sales,
                total_transactions,
                average_sale,
              ),
            ),
          )
        }

        [first_error, ..] -> {
          let Node(_, shared) = processor
          io.print_error(first_error)
          Node(Processed, shared)
        }
      }
    },
  )
}

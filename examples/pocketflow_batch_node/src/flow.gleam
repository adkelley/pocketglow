import nodes
import pocketflow.{type Fsm, type Shared, Fsm, Shared}
import types.{type Transitions, type Values, Done, Processor, Statistics, Values}

pub fn run(input_file: String, chunk_size: Int) -> Shared(Values) {
  let statistics = Statistics(0, 0, 0.0)
  let values = Values(input_file, chunk_size, statistics)

  pocketflow.flow(Fsm(Shared(values), Processor), process_csv)
}

fn process_csv(fsm: Fsm(Values, Transitions)) -> Shared(Values) {
  let Fsm(shared, transition) = fsm
  case transition {
    Processor -> process_csv(nodes.csv_processer(shared))
    Done -> shared
  }
}

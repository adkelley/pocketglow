pub type Statistics {
  Statistics(total_sales: Int, total_transactions: Int, average_sale: Float)
}

pub type Shared {
  Shared(input_file: String, chunk_size: Int, statistics: Statistics)
}

pub type Start {
  Start
}

pub type Processed {
  Processed
}

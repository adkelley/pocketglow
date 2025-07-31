pub type Statistics {
  Statistics(total_sales: Int, total_transactions: Int, average_sale: Float)
}

pub type Values {
  Values(input_file: String, chunk_size: Int, statistics: Statistics)
}

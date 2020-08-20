resource "elasticsearch_index" "companies" {
  name = "companies"
  mappings = file("../elasticsearch/mappings/companies.json")
  number_of_replicas = 1
  number_of_shards = 1
}
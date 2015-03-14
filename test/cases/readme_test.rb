# require 'cases/helper'

# class ReadmeTest < ActiveSupport::TestCase
#   setup do
#     @old_root = GQL.root_class
#     @old_list = GQL.default_list_class
#     @old_types = GQL.field_types.dup

#     load 'fixtures/example.rb'
#   end

#   teardown do
#     GQL.field_types = @old_types
#     GQL.default_list_class = @old_list
#     GQL.root_class = @old_root
#   end

#   test "readme example works as advertised" do
#     actual = GQL.execute(<<-QUERY_STRING).to_json
#       user(<token>) {
#         id,
#         is_admin,
#         full_name as name,
#         created_at { year, month } as created_year_and_month,
#         created_at.format("long") as created,
#         account {
#           bank_name,
#           iban,
#           saldo as saldo_string,
#           saldo {
#             currency,
#             cents   /* silly block comment */
#           }
#         },
#         albums.first(2) {
#           count,
#           edges {
#             cursor,
#             node {
#               artist,
#               title,
#               songs.first(2) {
#                 edges {
#                   id,
#                   title.upcase as upcased_title,
#                   title.upcase.length as upcased_title_length
#                 }
#               }
#             }
#           }
#         }
#       }

#       <token> = "ma"  // a variable
#     QUERY_STRING

#     expected = '{"id":"ma","is_admin":true,"name":"Martin Andert","created_year_and_month":{"year":2010,"month":3},"created":"March 06, 2010 13:03","account":{"bank_name":"Foo Bank","iban":"987654321","saldo_string":"100000.00 EUR","saldo":{"currency":"EUR","cents":10000000}},"albums":{"count":2,"edges":[{"cursor":1,"node":{"artist":"Metallica","title":"Black Album","songs":{"edges":[{"id":1,"upcased_title":"ENTER SANDMAN","upcased_title_length":13},{"id":2,"upcased_title":"SAD BUT TRUE","upcased_title_length":12}]}}},{"cursor":2,"node":{"artist":"Nirvana","title":"Nevermind","songs":{"edges":[{"id":5,"upcased_title":"SMELLS LIKE TEEN SPIRIT","upcased_title_length":23},{"id":6,"upcased_title":"COME AS YOU ARE","upcased_title_length":15}]}}}]}}'

#     assert_equal expected, actual
#   end
# end

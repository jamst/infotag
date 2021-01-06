# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# email to me!
role = Role.create(name:"admin",name_cn:"管理员")
em = Employee.create(email:"107422244@qq.com",password:"11111111",name:"jamst",role_ids:[role.id])

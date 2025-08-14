# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

admins = [
  {
    email: "ihera2@uillinois.edu",
    first_name: "Ian",
    last_name: "Heraty"
  },
  {
    email: "diamondm@uillinois.edu",
    first_name: "Morgan",
    last_name: "Diamond"
  },
  {
    email: "raghu@firstdraft.com",
    first_name: "Raghu",
    last_name: "Betina"
  },
  {
    email: "sjaime@uillinois.edu",
    first_name: "Sanjuana",
    last_name: "Jaime-Nix"
  },
  {
    email: "tula@uillinois.edu",
    first_name: "Tula",
    last_name: "Kuechenmeister"
  },
  {
    email: "homar4@uillinois.edu",
    first_name: "Haneen",
    last_name: "Omar"
  }
]

# Create Users
admins.each do |user_info|
  user = User.create(user_info.merge(password: "password"))
  user.add_role(:admin)
end

teaching_assistants = [
  {
    email: "mary@dpi.dev",
    first_name: "Mary",
    last_name: "Webby"
  },
  {
    email: "calvin@dpi.dev",
    first_name: "Calvin",
    last_name: "Armstrong"
  },
  {
    email: "aldo@dpi.dev",
    first_name: "Aldo",
    last_name: "Portillo"
  },
  {
    email: "margo@dpi.dev",
    first_name: "Margo",
    last_name: "Potylitsyna"
  },
  {
    email: "benny@dpi.dev",
    first_name: "Benny",
    last_name: "Jorman"
  },
  {
    email: "jose@dpi.dev",
    first_name: "Jose",
    last_name: "De Oca Morfin"
  },
  {
    email: "annie@dpi.dev",
    first_name: "Annie",
    last_name: "Huynh"
  },
  {
    email: "carlos@dpi.dev",
    first_name: "Carlos",
    last_name: "Castaneda"
  },
  {
    email: "alex@dpi.dev",
    first_name: "Alex",
    last_name: "Mompremier"
  },
  {
    email: "thierry@dpi.dev",
    first_name: "Thierry",
    last_name: "Chau"
  },
  {
    email: "jorge@dpi.dev",
    first_name: "Jorge",
    last_name: "Gomez"
  },
  {
    email: "fidel@dpi.dev",
    first_name: "Fidel",
    last_name: "Leal"
  },
  {
    email: "darryl@dpi.dev",
    first_name: "Darryl",
    last_name: "Williams"
  },
  {
    email: "ximena@dpi.dev",
    first_name: "Ximena",
    last_name: "Castillo"
  },
  {
    email: "dustin@dpi.dev",
    first_name: "Dustin",
    last_name: "Doyle"
  },
  {
    email: "jazmine@dpi.dev",
    first_name: "Jazmine",
    last_name: "Tran"
  },
  {
    email: "john@dpi.dev",
    first_name: "John",
    last_name: "Leavell"
  }
]

teaching_assistants.each do |user_info|
  user = User.create(user_info.merge(password: "password"))
  user.enrollments.create(cohort: Cohort.first, role: :teaching_assistant)
end

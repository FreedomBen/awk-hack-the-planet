#!/usr/bin/env ruby

def first_names
  %w[
    Liam
    Noah
    William
    James
    Logan
    Benjamin
    Mason
    Elijah
    Oliver
    Jacob
    Oliver
    Harry
    George
    Noah
    Jack
    Jacob
    Leo
    Oscar
    Charlie
    Muhammad
    Emma
    Olivia
    Ava
    Isabella
    Sophia
    Mia
    Charlotte
    Amelia
    Evelyn
    Abigail
    Olivia
    Amelia
    Isla
    Ava
    Emily
    Isabella
    Mia
    Poppy
    Ella
    Lily
    Byron  
    Leonard
    Alberta
    Hilary
    Tresa
    Octavio
    Gladis
    Nelia
    Angie
    Levi
    Joanna
    Veda
    Maribeth
    Glynis
    Ramonita
    Andria
    Merrie
    Rosalyn
    Karly
    Siu
    Elvera
    Adelina
    Thi
    Blondell
    Milan
    Illa
    Brain
    Hyman
    Louanne
    Christiana
    Malik
    Lizeth
    Eva
    Jeffry
    Ilene
    Lauralee
    Justina
    Gabriele
    Grazyna
    Shonna
    Deeann
    Maryrose
    Belkis
    Robbie
    Beata
    Fallon
    Lettie
    Dong
    Lyndia
    Ashleigh
  ]
end

def last_names
  %w[
    Dipasquale
    Windsor
    Drager
    Marenco
    Ung
    Gajewski
    Aguilera
    Fugate
    Bing
    Wingler
    Heine
    Drumheller
    Ptacek
    Hedge
    Fiorillo
    Wehr
    Pinnix
    Schock
    Ormond
    Grigg
    Hamel
    Casale
    Aguinaldo
    Shiflett
    Ransdell
    Scioneaux
    Merrell
    Bonnell
    Woodring
    Shain
    Hannah
    Blauvelt
    Portwood
    Haydel
    Gaillard
    Pack
    Mcgaughey
    Perdomo
    Campoverde
    Ibrahim
    Esposito
    Kenney
    Whitesell
    Harriman
    Bixler
    Aburto
    Monzon
    Felkins
    Ishibashi
  ]
end

def wage
  "#{Random.rand(0..60)}.#{Random.rand(0..99)}".to_f
end

def hours
  "#{Random.rand(20..50)}".to_i
end

def office
  %w[
    Lehi
    MountainView
    Seattle
    Raleigh
    NewYork
    Concord
    Manchester
  ].shuffle.first
end

def title
  %w[
    SoftwareEngineer
    DevOps
    MechanicalEngineer
    HumanResources
  ].shuffle.first
end

def names
  retval = []
  first_names.each do |fname|
    last_names.each do |lname|
      retval.push("#{fname} #{lname}")
    end
  end
  retval
end

def rand_year
  (1975..2018).to_a.shuffle.first
end

def rand_month
  (1..12).to_a.shuffle.first.to_s.rjust(2, "0")
end

def rand_day
  (1..28).to_a.shuffle.first.to_s.rjust(2, "0")
end

def start_date
  "#{rand_year}/#{rand_month}/#{rand_day}"
end

def constants
  [
    line("Linus Torvalds", "1599.01", "40", "Lehi", "CEO", "1993/04/16"),
    line("Homer Simpson", "15.12", "33", "Springfield", "NuclearPower", "1993/04/16"),
    line("Sergey Brin", "1299", "40", "MountainView", "COO", "1993/04/16"),
    line("Larry Page", "1299", "40", "MountainView", "VPEng", "1993/04/16"),
    line("Benjamin Porter", "678", "40", "Lehi", "Janitor", "1993/04/16"),
  ]
end

# These argument names look like typos and drive me kind of crazy, but they aren't typos.
# They are to avoid name collision with the functions defined above
def line(nam, wag, hour, offic, titl, start_dat)
  "#{nam.split(' ')[0]}\t#{nam.split(' ')[1]}\t#{wag}\t#{hour}\t#{offic}\t#{titl}\t#{start_dat}"
end

File.open('payroll.tsv', 'w') do |file|
  file.write("FirstName\tLastName\tHourlyWage\tHoursWorked\tOffice\tTitle\tStartDate\n")
  file.write(
    names
      .map { |emp| line(emp, wage, hours, office, title, start_date) }
      .concat(constants)
      .shuffle
      .join("\n")
  )
end

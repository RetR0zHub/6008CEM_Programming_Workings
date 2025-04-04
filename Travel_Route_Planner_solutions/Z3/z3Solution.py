# # Problem selected - Tavel Route Planner
# in order to push and merge with GitHub: git push GitHub_Repo main

# Problem selected - Tavel Route Planner

# Path for testing:  python3 Travel_Route_Planner_solutions/Z3/z3Solution.py

# Based of the approximate road distances between each city
# Travel Route planner idea: Distance from different paths starting from london (Node 1)

# Path Tree: 1 London (is directly connected to) -> Bath(111 Miles), Cambridge(60), Birmingham(119)

#           2 Birmingham -> Manchester(87), Swansea(143), Liverpool(99), Leicester(45)

#           3 Bath -> Swansea(96), London(100) 

#           4 Cambridge -> Leicester(72), Peterborough(43), London(60)

#           5 Peterborough -> Sheffield(93), Cambridge(43), Leicester(41)

#           6 Leicester -> Peterborough(41), Sheffield(70), Birmingham(45), Cambridge(72)

#           7 Sheffield  -> Manchester(42), Peterborough(93), Leicester(70)

#           8 Manchester -> Liverpool(33), Birmingham(87), Sheffield(42)

#           9 Liverpool -> Manchester(33), Swansea(167), Birmingham(99)

#           10 Swansea -> Birmingham(143), Bath(96), Liverpool(167)

# 1st process is to find the shortest path 
# Example for output:
# If want to travel from London -> Swansea 
# All routes include
#   London -> Bath -> Swansea = 111 + 96 = 207
#   London -> Birmingham -> Swansea = 119 + 143 = 262
#   London -> Cambridge -> Peterborough -> Sheffield -> Manchester -> Liverpool -> Swansea = 60 + 43 + 93 + 42 + 33 + 167 = 438
#   London -> Cambridge -> Leicester -> Sheffield -> Manchester -> Liverpool -> Swansea = 60 + 72 + 70 + 42 + 33 + 167 = 444
#   + extra paths if wanting to go through specific cities (e.g. Liverpool: London -> Birmingham -> Liverpool -> Swansea etc.)
# Then the purpose of the algorithm is to find which route would take the shortest distance (time) 
#   So in this case, the algorithm should suggest [ London -> Bath -> Swansea at 207 Miles]

# Developing an algorithm to work out the shortest path between cities with assitance of generative Ai:

from z3 import *

# must initialise a list of cities and the distances between them
# Changed to Graph Representation (adjacency list with distances ) instead of Dictionary grouping 

cityGraph = { "London" : { "Birmingham" : 119 , "Bath" : 111 , "Cambridge" : 60 } ,

              "Birmingham" : { "Manchester" : 87 , "Swansea" : 143 ,  "Liverpool" : 99 ,  "Leicester" : 45 },

              "Bath" : { "Swansea" : 96 , "London" : 100 } ,
              
              "Cambridge" : { "Leicester" : 72 , "Peterborough" : 43 , "London" : 60} , 

              "Peterborough" : { "Sheffield" : 93 , "Cambridge" : 43 , "Leicester" : 41 } , 
              
              "Leicester" : { "Peterborough" : 41 , "Sheffield" : 70 , "Birmingham" : 45 , "Cambridge" : 72 }, 
              
              "Sheffield" : { "Manchester" : 42 , "Peterborough" : 93 , "Leicester" : 70 }, 
              
              "Manchester" : { "Liverpool" : 33 , "Birmingham" : 87 , "Sheffield" : 42 },
              
              "Liverpool" : { "Manchester" : 33 , "Swansea" : 167 , "Birmingham" : 99 },
              
              "Swansea" : { "Birmingham" : 143 , "Bath" : 96 , "Liverpool" : 167 }  } 


# Utalising solver = Optimize() to find shortest route 
def shortestPath(graphOfCities, start, target):
    solver = Optimize()
    cityIntegerVar = {city: Int(city) for city in graphOfCities}  # create Z3 integer variables for each city, representing distance the from the 'start' city 
    used = { (c1, c2): Bool(f"used_{c1}_{c2}") for c1 in graphOfCities for c2 in graphOfCities[c1] }  # Boolean variables to track which path routes are used 

    solver.add(cityIntegerVar[start] == 0)                            # 1st Constraint - Start city has a distance of 0 
    for city in graphOfCities:
        solver.add(cityIntegerVar[city] >= 0)                         # 2nd Constraint - Make sure every city's distance must be positive and not negative
    for city in graphOfCities:
        for neighbor, dist in graphOfCities[city].items():                                                      # If edge is used, the neighbor must have correct distance
            solver.add(Implies(used[(city, neighbor)], cityIntegerVar[neighbor] == cityIntegerVar[city] + dist)) # 3rd Constraint - if the current shortest path is used, its z3int variable is added to the cost of the total distance
    for city in graphOfCities:                                    
        if city != start:                                                                                 #  Exactly one path reaches each city (except start)
            solver.add(AtMost(*[used[(c, city)] for c in graphOfCities if city in graphOfCities[c]], 1))  # 4th Constraint - City is not entered from multiple locations with no cycles/loops
            solver.add(AtLeast(*[used[(c, city)] for c in graphOfCities if city in graphOfCities[c]], 1)) # 5th Constraint - City is reachable with no dead ends
    solver.minimize(cityIntegerVar[target])                           # Optimization making sure the minimum distance to the target location is found 

    if solver.check() == sat:                                         # Solver checks for if a valid solution is found (Shortest Path to Target)
        model = solver.model()
        shortestDistance = model[cityIntegerVar[target]].as_long()
        path = [target]                                         
        while path[-1] != start:                                     # While loop to trace back to start from target, linking shortest path cities on the return until path == start
            for city in graphOfCities:
                if (city, path[-1]) in used and model[used[(city, path[-1])]] == True:
                    path.append(city)
                    break
        path.reverse()                                               # Reversed to get correct order
        print("Shortest Route Available:", " -> ".join(path))
        print("Total Distance:", shortestDistance)
        return path, shortestDistance
    else:
        print("No Route Available.")
        return None, None

#TEST - success! 
#shortestPath(cityGraph, "Bath", "Leicester")

print("Welcome To The Route Travel Planner! (Choose from: London, Birmingham, Bath, Cambridge, Peterborough, Leicester, Sheffield, Manchester, Liverpool and Swansea)")
targetCity = input("Where would you like to go?: ")
startCity = input ("And where would you like to start?: ")

print("\nHow would you like your journey to be optimized. \n\n 1. Shortest Route (Least distance travelled) \n")
optChoice = input("Please choose a numeber: ")
if optChoice == "1":
  shortestPath(cityGraph, startCity, targetCity)
else:
  print ("Please Try again")
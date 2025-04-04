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

cities = ["London", "Birmingham", "Bath", "Cambridge", "Peterborough", "Leicester", "Sheffield", "Manchester", "Liverpool", "Swansea"]

# Dictionanary Grouping - acts as an adjacency list with each tuple representing an edge between cities; distance is the value of that edge [ ("x", "y"): value] + Unidirected graph
distances = { ("London", "Birmingham") : 119 , ("London", "Bath") : 111 , ("London", "Cambridge") : 60 ,

              ("Birmingham", "Manchester") : 87 , ("Birmingham", "Swansea") : 143 , ("Birmingham", "Liverpool") : 99 , ("Birmingham", "Leicester") : 45 ,

              ("Bath", "Swansea") : 96 , ("Bath", "London") : 100 ,
              
              ("Cambridge", "Leicester") : 72 , ("Cambridge", "Peterborough") : 43 , ("Cambridge", "London") : 60 , 

              ("Peterborough", "Sheffield") : 93 , ("Peterborough", "Cambridge") : 43 , ("Peterborough", "Leicester") : 41 , 
              
              ("Leicester", "Peterborough") : 41 , ("Leicester", "Sheffield") : 70 , ("Leicester", "Birmingham") : 45 , ("Leicester", "Cambridge") : 72 , 
              
              ("Sheffield", "Manchester") : 42 , ("Sheffield", "Peterborough") : 93 , ("Sheffield", "Leicester") : 70 , 
              
              ("Manchester", "Liverpool") : 33 , ("Manchester", "Birmingham") : 87 , ("Manchester", "Sheffield") : 42 ,
              
              ("Liverpool", "Manchester") : 33 , ("Liverpool", "Swansea") : 167 , ("Liverpool", "Birmingham") : 99 ,
              
              ("Swansea", "Birmingham") : 143 , ("Swansea", "Bath") : 96 , ("Swansea", "Liverpool") : 167 } 


def allPossibleRoutes(cities, distances, start, target):
    solve = Solver()
    totalCityNumber = len(cities)
    cityIndex = {cities[i]: i for i in range(totalCityNumber)} # Maps each city name to a unique integer
    if start not in cityIndex or target not in cityIndex:   # If either start or target is not in the cityIndex, there is no path and therefore and empty list is returned 
        return []  
    
    startIndex, targetIndex = cityIndex[start], cityIndex[target]   # coverts both the start and target cities into their corresponding index 
    maxPathLength = totalCityNumber
    order = [Int(f'city_{i}') for i in range(totalCityNumber)]    # under order, the creation of Z3 Variables to represent the sequence of city indicies in the path 
    solve.add(Distinct(order))                              # Add solver rule that all paths must be Distinct (no repeats)
    for i in range(maxPathLength):
        solve.add(order[i] >= 0, order[i] < totalCityNumber) # Add Solver rule that ensures each order variable must be a valid city index, between order and the city length - preventing any invaild index being used 

    
    solve.add(order[0] == startIndex)                    # Add Solver rule that the first city in the path must be the start city
    solve.add(order[- 1] == targetIndex)   # Add Solver rule that the last city must be in the path but the position won't be forced
    validPaths = []
    while solve.check() == sat:                     # while loop running with the solver constantly checking for satisfiable solutions (valid paths) until there are none left
        model = solve.model()                       
        routeIndex = [model[order[i]].as_long() for i in range(totalCityNumber)]   # Conversion of city indicies back to city names, applying the Z3 solution with model solve, after converting the Z3 integer Value into a pyhton integer (city index)
        route = [cities[idx] for idx in routeIndex] 
        if target in route:
          targetPosition = route.index(target)
          route = route[:targetPosition + 1]
        
        totalDistance = 0
        validRoute = True   
        for i in range(len(route) - 1):
            if (route[i], route[i+1]) in distances:
                totalDistance += distances[(route[i], route[i+1])]
            elif (route[i+1], route[i]) in distances:  # If bidirectional
                totalDistance += distances[(route[i+1], route[i])]
            else:
                validRoute = False  # No direct connection → Invalid path
                print("Invalid path, skipping:", route)  # Debug print
                break

        if validRoute:
            validPaths.append((route, totalDistance))

        solve.add(*[order[i] != model[order[i]] for i in range(len(route))]) # Block the current solution so Z3 finds new ones

    return validPaths


start = "London"
target = "Birmingham"
paths = allPossibleRoutes(cities, distances, start, target)

for route, distance in paths:
    print(f"Path: {route}, Distance: {distance}")

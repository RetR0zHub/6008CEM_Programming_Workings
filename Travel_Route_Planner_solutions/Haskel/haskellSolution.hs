-- # Problem selected - Tavel Route Planner
-- in order to push and merge with GitHub: git push GitHub_Repo main

-- Problem selected - Tavel Route Planner

-- Path for testing: stack ghci | :l  Travel_Route_Planner_solutions/Haskel/haskellSolution.hs

-- Based of the approximate road distances between each city
-- Travel Route planner idea: Distance from different paths starting from london (Node 1)

-- Path Tree: 1 London (is directly connected to) -> Bath(111 Miles), Cambridge(60), Birmingham(119)

--           2 Birmingham -> Manchester(87), Swansea(143), Liverpool(99), Leicester(45)

--           3 Bath -> Swansea(96), London(100) 

--           4 Cambridge -> Leicester(72), Peterborough(43), London(60)

--           5 Peterborough -> Sheffield(93), Cambridge(43), Leicester(41)

--           6 Leicester -> Peterborough(41), Sheffield(70), Birmingham(45), Cambridge(72)

--           7 Sheffield  -> Manchester(42), Peterborough(93), Leicester(70)

--           8 Manchester -> Liverpool(33), Birmingham(87), Sheffield(42)

--           9 Liverpool -> Manchester(33), Swansea(167), Birmingham(99)

--           10 Swansea -> Birmingham(143), Bath(96), Liverpool(167)

-- 1st process is to find the shortest path 
-- Example for output:
-- If want to travel from London -> Swansea 
-- All routes include
--   London -> Bath -> Swansea = 111 + 96 = 207
--   London -> Birmingham -> Swansea = 119 + 143 = 262
--   London -> Cambridge -> Peterborough -> Sheffield -> Manchester -> Liverpool -> Swansea = 60 + 43 + 93 + 42 + 33 + 167 = 438
--   London -> Cambridge -> Leicester -> Sheffield -> Manchester -> Liverpool -> Swansea = 60 + 72 + 70 + 42 + 33 + 167 = 444
--   + extra paths if wanting to go through specific cities (e.g. Liverpool: London -> Birmingham -> Liverpool -> Swansea etc.)
-- Then the purpose of the algorithm is to find which route would take the shortest distance (time) 
--   So in this case, the algorithm should suggest [ London -> Bath -> Swansea at 207 Miles]

-- Developing an algorithm to work out all the paths between cities with assitance of generative Ai:
-- Depth-first search (DFS) approach 

import Data.List 
import Data.Ord
import qualified Data.Map as Map
type City = String
type Distance = Int
type Graph = Map.Map City [(City, Distance)]
type Path = ([City], Distance)

-- using graph and .Map from Data.Map, an adjacency list is formed - a list of tuples contianing key cities and the list of cities they are connected to + the distances between them
-- .fromList builds a map from an unordered list of key/value pairs 
graph :: Graph
graph = Map.fromList
    [ ("London", [("Bath", 111), ("Cambridge", 60), ("Birmingham", 119) ])

    , ("Birmingham", [("Manchester", 87), ("Swansea", 143), ("Liverpool", 99), ("Leicester", 45)])

    , ("Bath", [("Swansea", 96), ("London", 100)])

    , ("Cambridge", [("Leicester", 72), ("Peterborough", 43), ("London", 60)])

    , ("Peterborough", [("Sheffield", 93), ("Cambridge", 43), ("Leicester", 41)])

    , ("Leicester", [("Peterborough", 41), ("Sheffield", 70), ("Birmingham", 45), ("Cambridge", 72)])

    , ("Sheffield", [("Manchester", 42), ("Peterborough", 93), ("Leicester", 70)])

    , ("Manchester", [("Liverpool", 33), ("Birmingham", 87), ("Sheffield", 42)])

    , ("Liverpool", [("Manchester", 33), ("Swansea", 167), ("Birmingham", 99)])

    , ("Swansea", [("Birmingham", 143), ("Bath", 96), ("Liverpool", 167)])

    ]

-- Recursive function to find all paths from start to target
findRoutes :: Graph -> City -> City -> [City] -> Distance -> [Path] -- Utalises function gaurds to separate recursive case and base case 
-- Map.lookup :: Ord k => k -> Map k a -> Maybe a - Function returns a maybe type
findRoutes graph start target visited distanceInMiles
    | start == target = [ (reverse (target:visited), distanceInMiles) ] -- Base case: Recursive start is the target -> reversing the visited list after prepending the target, returning the full path found and total distance travelled
    | otherwise =
        case Map.lookup start graph of -- case expression used for pattern matching: different action taken dependant on the pattern of value (nothing OR Just neighbors)
            Nothing -> []   -- if the start does not exsist or the target is never reached an empty list is returned, representing no path 
            Just neighbors ->
                [ path | (nextCity, d) <- neighbors -- iterates (<-) over all neighbouring cities, extracting elements from a list and decomposing each tuple into nextCity and d (representing distance)
                , nextCity `notElem` visited -- Filters out cities already visited (" next city is not an element of visited ") 
                , path <- findRoutes graph nextCity target (start:visited) (distanceInMiles + d) ] -- path becomes the recursion of findRoutes on nextCity 

-- Test wrapper function - Called to check if the findRoutes function works without having to initialise the empty list and 0 (for distance)
allRoutes :: Graph -> City -> City -> [Path]
allRoutes graph from to = findRoutes graph from to [] 0

-- Developing an algorithm to work out the SHORTEST paths between the graph of cities:
shortestRoute :: Graph -> City -> City -> Maybe Path
shortestRoute graph start target =
    let routes = findRoutes graph start target [] 0
    in if null routes
       then Nothing  -- No path found
       else Just (minimumBy (comparing snd) routes)  
       -- minimumBy imported from Data.List (finds the smallest distance), -- comparing imported from Data.Ord (use to make the second element distance the comparison)
       -- snd extracts the second element of the tuple routes (distance)

-- Adding a main function to run in the IO
main :: IO ()
main = do
    putStrLn "Enter starting city: (Choose from: London, Birmingham, Bath, Cambridge, Peterborough, Leicester, Sheffield, Manchester, Liverpool and Swansea)  "
    start <- getLine
    putStrLn "Enter destination city: "
    target <- getLine
    case shortestRoute graph start target of
        Just (route, distance) -> do
            putStrLn $ "Shortest path: " ++ intercalate " -> " route
            putStrLn $ "Total distance: " ++ show distance ++ " miles"
        Nothing -> putStrLn "No route found."



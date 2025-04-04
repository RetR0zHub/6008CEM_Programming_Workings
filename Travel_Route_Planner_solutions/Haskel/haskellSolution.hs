-- # Problem selected - Tavel Route Planner
-- in order to push and merge with GitHub: git push GitHub_Repo main

-- Problem selected - Tavel Route Planner

-- Path for testing: swipl Travel_Route_Planner_solutions/Prolog/prologSolution.pl 

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


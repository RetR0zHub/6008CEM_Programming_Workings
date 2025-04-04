% in order to push and merge with GitHub: git push GitHub_Repo main

%% Problem selected - Tavel Route Planner

% Path for testing: swipl Travel_Route_Planner_solutions/Prolog/prologSolution.pl 

% Based of the approximate road distances between each city
% Travel Route planner idea: Distance from different paths starting from london (Node 1)

% Path Tree: 1 London (is directly connected to) -> Bath(111 Miles), Cambridge(60), Birmingham(119)

%           2 Birmingham -> Manchester(87), Swansea(143), Liverpool(99), Leicester(45)

%           3 Bath -> Swansea(96), London(100) 

%           4 Cambridge -> Leicester(72), Peterborough(43), London(60)

%           5 Peterborough -> Sheffield(93), Cambridge(43), Leicester(41)

%           6 Leicester -> Peterborough(41), Sheffield(70), Birmingham(45), Cambridge(72)

%           7 Sheffield  -> Manchester(42), Peterborough(93), Leicester(70)

%           8 Manchester -> Liverpool(33), Birmingham(87), Sheffield(42)

%           9 Liverpool -> Manchester(33), Swansea(167), Birmingham(99)

%           10 Swansea -> Birmingham(143), Bath(96), Liverpool(167)

% 1st process is to find the shortest path 
% Example for output:
% If want to travel from London -> Swansea 
% All routes include
%   London -> Bath -> Swansea = 111 + 96 = 207
%   London -> Birmingham -> Swansea = 119 + 143 = 262
%   London -> Cambridge -> Peterborough -> Sheffield -> Manchester -> Liverpool -> Swansea = 60 + 43 + 93 + 42 + 33 + 167 = 438
%   London -> Cambridge -> Leicester -> Sheffield -> Manchester -> Liverpool -> Swansea = 60 + 72 + 70 + 42 + 33 + 167 = 444
%   + extra paths if wanting to go through specific cities (e.g. Liverpool: London -> Birmingham -> Liverpool -> Swansea etc.)
% Then the purpose of the algorithm is to find which route would take the shortest distance (time) 
%   So in this case, the algorithm should suggest [ London -> Bath -> Swansea at 207 Miles]

% London connected cities and distances
distanceBetween(london, bath, 111). distanceBetween(london, birmingham, 119). distanceBetween(london, cambridge, 60).

% Birmingham connected cities and distances
distanceBetween(birmingham, manchester, 87). distanceBetween(birmingham, swansea, 143). distanceBetween(birmingham, liverpool, 99). distanceBetween(birmingham, leicester, 45).

% Bath connected cities and distances
distanceBetween(bath, swansea, 96). distanceBetween(bath, london, 100).

% Cambridge connected cities and distances
distanceBetween(cambridge, leicester, 72). distanceBetween(cambridge, peterborough, 43). distanceBetween(cambridge, london, 60).

% Peterborough connected cities and distances
distanceBetween(peterborough, sheffield, 93). distanceBetween(peterborough, cambridge, 43). distanceBetween(peterborough, leicester, 41).

% Leicester connected cities and distances
distanceBetween(leicester, peterborough, 41). distanceBetween(leicester, sheffield, 70). distanceBetween(leicester, birmingham, 45). distanceBetween(leicester, cambridge, 72).

% Sheffield connected cities and distances
distanceBetween(sheffield, manchester, 42). distanceBetween(sheffield, peterborough, 93). distanceBetween(sheffield, leicester, 70).

% Manchester connected cities and distances
distanceBetween(manchester, liverpool, 33). distanceBetween(manchester, birmingham, 87). distanceBetween(manchester, sheffield, 42).

% Liverpool connected cities and distances
distanceBetween(liverpool, manchester, 33). distanceBetween(liverpool, birmingham, 99). distanceBetween(liverpool, swansea, 167).

% Swansea connected cities and distances
distanceBetween(swansea, birmingham, 143). distanceBetween(swansea, bath, 96). distanceBetween(swansea, liverpool, 167).

% Can run a test to see if all the connected locations distances match and the prolog stores these as hardcoded True results
%  Test code: distanceBetween(Start, Target, DistanceInMiles). - Gives a layout of start locations, thier connected targets and the distance between them in miles (using ';' to continue)

% Calculate the Shortest Travel Route recusivly - looking for all possible paths (utalised Ai here to develop and understand pathfinding logic):
% Test will be London -> Swansea

% travelPath() is a recursive rule used to find all the possible paths from one location to another without repeating the same location twice
% Base Case
travelPath(Start, Target, [Start, Target] , DistanceInMiles, Visited):-
  distanceBetween(Start, Target, DistanceInMiles),
  \+ member(Target, Visited).  % Ensure Target has not been visited, to avoid cycles
 
% Recusive Case 
travelPath(Start, Target, [Start | Path], TotalDistanceInMiles, Visited):-
  distanceBetween(Start, Intermediate, DistanceInMiles),
  Intermediate \= Start, 
  \+ member(Intermediate, Visited),
  travelPath(Intermediate, Target, Path, SubDistance, [Intermediate | Visited]), 
  TotalDistanceInMiles is DistanceInMiles + SubDistance. % ^ Add Intermediate to visited list

% \+ - negation as failure, succeeds if the goal following it cannot be proven true: 
% if (Intermediate) or (Target) is in Visited it is a success causing ' \+ member(...) ' to FAIL! Preventing paths that used the already Visited location again to exsist.

% Intermediate \= Start : Ensures that the Intermediate location is not the same as the Start location - prevent loops


% allPossiblePathsBetween() used as a check to see the all the possible paths/routes between locations
  allPossiblePathsBetween(Start, Target, Path, Distance) :-
    travelPath(Start, Target, Path, Distance, [Start]). % Ensure Start is initilised as Visited, to prevent it from being duplicated in the Path creating looping journeys 


% Further code now utalises travelPath() in order to find the path of least DistanceTravelled - shortest route (utalised generative Ai)

allPathsFrom(Start, Target, PathsWithDistances) :-
    findall([Path, DistanceInMiles], travelPath(Start, Target, Path, DistanceInMiles, [Start]), PathsWithDistances).
% find all is a built-in predicate - findall(Template, Goal, Bag)
% Template - paths and distance, Goal - predicate that must hold true for the values to be collected, Bag - Results are stored here (PathsWithDistances)
% Every time a vaild path is found, it takes the form of [Path, DistanceInMiles] and is stored inside PathsWithDistances

% 1st Base Case - triggers when list of PathsWithDistances is empty and no path has been found (ShortestPath = [] , ShortestDistance = 9999999), 
% and so [none] and 0 (miles) is returned as the shortest path and shortest distance and the program is cut to prevent producing 2 answers with the second base case 
findShortestRoute([], [], 9999999, [none], 0):- !.

% 2nd Base Case - triggers when list of PathsWithDistances is empty leaving all paths checked, returing the shortest path and distance
findShortestRoute([], ShortestPath, ShortestDistance, ShortestPath, ShortestDistance).

% Recursive Case - Cuts the head of PathsWithDistances to compare if that is less than (<) the current stored distance (starts off as max 9999999)
findShortestRoute([[Path, DistanceInMiles] | Rest], CurrentPath, CurrentDistance, ShortestPath, ShortestDistance) :-
    ( DistanceInMiles < CurrentDistance ->
        findShortestRoute(Rest, Path, DistanceInMiles, ShortestPath, ShortestDistance)
    ; 
        findShortestRoute(Rest, CurrentPath, CurrentDistance, ShortestPath, ShortestDistance)
    ).

shortestRoute(Start, Target, ShortestPath, ShortestDistance) :-
    allPathsFrom(Start, Target, PathsWithDistances),
    findShortestRoute(PathsWithDistances, _, 9999999, ShortestPath, ShortestDistance).
% ShortestPath and ShortestDistance used as output variables to display the Shortest Route and the total distance travelled
% _ - place holder for CurrentPath as it will be initilised during search
% 9999999 - max distance allowing for smaller routes to be searched for


    

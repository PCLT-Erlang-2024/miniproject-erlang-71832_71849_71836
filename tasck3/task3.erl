-module(task3).
-export([start/0, loop_belt/3, loop_factory/2, loop_truck/2, factory/0]).

start() ->
    spawn(task3, factory, []).

factory() ->
    %% Constants
    NUM_TRUKS = 5,
    NUM_BELTS = 3,

    %% Creat 3 belts and 5 trucks
    Trucks = [spawn(task3, loop_truck, [Id,0]) || Id <- lists:seq(1, NUM_TRUKS)],
    Belts = [spawn(task3, loop_belt, [Id,Trucks,ok]) || Id <- lists:seq(1, NUM_BELTS)],
    
    loop_factory(Belts, 0).

loop_factory(Belts, Id) ->

    Size = rand:uniform(4),  %% TASK2: Size of the package between 1-4
    
    Package = {package, Id+1, Size},

    %% Sending packages to the belt randomly
    Belt = lists:nth(rand:uniform(length(Belts)), Belts),
    Belt ! {pass, Package},
    io:format("Factory: Package ~p added in the belt~n", [Id+1]),
    timer:sleep(50),
    loop_factory(Belts, Id+1).


loop_belt(Id, Trucks, Ctrl) ->
    Truck = lists:nth(rand:uniform(length(Trucks)), Trucks),

    timer:sleep(80),
    case Ctrl of
        ok ->
            receive
                {pass, {package, PackId, Size}} ->
                    io:format("Belt ~p: Package ~p added~n", [Id, PackId]),
                    NewPackage = {package, PackId, Size}
            end;

        {false, PackId, Size}  ->
            NewPackage = {package, PackId, Size},
            io:format("Belt ~p: Redistributing package ~p ~n",[Id, PackId])

    end,

    Truck ! {NewPackage, {self(), Id}},

    receive
      {done, NewCtrl} ->
        loop_belt(Id, Trucks, NewCtrl)
    end.


loop_truck(Id, Capacity) ->
    receive
        {{package, PackId, Size}, {Belt, BeltId}} ->

            NewCapacity = Capacity + Size,

            if 
                NewCapacity == 10 ->   %% TASK2: max capacity 10
                    io:format("Truck ~p is full, dispatching with ~p of capacity~n", [Id, NewCapacity]),
                    
                    io:format("Belt ~p pause ~n",[BeltId]),
                    timer:sleep(100),  %% TASK3: time to be replaced
                    io:format("Belt ~p restart ~n",[BeltId]),

                    Belt ! {done, {false, PackId, Size}},

                    loop_truck(Id, 0);

                NewCapacity > 10 ->  %% TASK2: case if the package is too big
                    io:format("Truck ~p does not have enough space (~p) for the package ~p (~p) ~n",[Id,10-Capacity,PackId,Size]),
                    Belt ! {done, {false, PackId, Size}},
                    loop_truck(Id, Capacity);
           
                true ->
                    Belt ! {done, ok},
                    io:format("Truck ~p with space of ~p: Loaded package ~p with size ~p~n", [Id, 10-Capacity, PackId, Size]),
                    loop_truck(Id, NewCapacity)
                end
    end.

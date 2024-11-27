-module(task2).
-export([start/0, loop_belt/3, loop_factory/2, loop_truck/2, factory/0]).

start() ->
    spawn(task1, factory, []).

factory() ->
    %% Constants
    NUM_TRUKS = 5,
    NUM_BELTS = 3,

    %% Creat 3 belts and 5 trucks
    Trucks = [spawn(task1, loop_truck, [Id,0]) || Id <- lists:seq(1, NUM_TRUKS)],
    Belts = [spawn(task1, loop_belt, [Id,Trucks,ok]) || Id <- lists:seq(1, NUM_BELTS)],
    
    loop_factory(Belts, 0).

loop_factory(Belts, Id) ->

    Package = {package, Id+1},

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
                {pass, {package, PackId}} ->
                    io:format("Belt ~p: Package ~p added~n", [Id, PackId]),
                    NewPackage = {package, PackId}
            end;

        {false, PackId}  ->
            NewPackage = {package, PackId},
            io:format("Belt ~p: Redistributing package ~p ~n",[Id, PackId])

    end,

    Truck ! {NewPackage, self()},

    receive
      {done, NewCtrl} ->
        loop_belt(Id, Trucks, NewCtrl)
    end.


loop_truck(Id, Capacity) ->
    receive
        {{package, PackId}, Belt} ->

            if 
                Capacity > 6 ->   %% MAX CAPACITY SIX
                    io:format("Truck ~p is full, dispatching with 6 packages~n", [Id]),
                    Belt ! {done, {false, PackId}},
                    loop_truck(Id, 0);
           
                true ->
                    Belt ! {done, ok},
                    io:format("Truck ~p: Loaded package ~p~n", [Id, PackId]),
                    loop_truck(Id, Capacity+1)
                end
    end.

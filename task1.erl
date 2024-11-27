-module(task1).
-export([start/0, loop_belt/3, loop_factory/2, loop_truck/2, factory/0]).

start() ->
    spawn(task1, factory, []).

factory() ->
    %% Creat 3 belts and 4 trucks
    Trucks = [spawn(task1, loop_truck, [Id,0]) || Id <- lists:seq(1, 4)],
    Belts = [spawn(task1, loop_belt, [Id,Trucks,ok]) || Id <- lists:seq(1, 3)],
    
    loop_factory(Belts, 0).

loop_factory(Belts, Id) ->

    Package = {package, Id+1},

    %% Sending packages to the belt randomly
    Belt = lists:nth(rand:uniform(length(Belts)), Belts),
    Belt ! Package,
    io:format("Factory: Package ~p added in the belt~n", [Id+1]),
    timer:sleep(1000),
    loop_factory(Belts, Id+1).


loop_belt(Id, Trucks, Ctrl) ->
    Truck = lists:nth(rand:uniform(length(Trucks)), Trucks),

    case Ctrl of
        ok ->
            receive
                {package, PackId} ->
                    io:format("Belt ~p: Package ~p added~n", [Id, PackId]),
                    NewPackage = {package, PackId}
            end;

        {package, PackId}  ->
            NewPackage = {package, PackId},
            io:format("Belt ~p: Redistributing package ~p ~n ",[Id, PackId])

    end,

    Truck ! {NewPackage, self()},
    receive
      NewCtrl ->
        loop_belt(Id, Trucks, NewCtrl)
    end.


loop_truck(Id, Capacity) ->
    receive
        {{package, PackId}, Belt} ->

            if 
                Capacity > 10 ->   %% MAX CAPACITY TEN
                    Belt ! {package, PackId},
                    io:format("Truck ~p is full, dispatching with 10 packages~n", [Id]),
                    loop_truck(Id, 0);
           
                true ->
                    Belt ! ok,
                    io:format("Truck ~p: Loaded ~p package~n", [Id, PackId]),
                    loop_truck(Id, Capacity+1)
                end
    end.

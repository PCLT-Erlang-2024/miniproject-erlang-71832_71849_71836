### General Functionality

This code implements a package handling system modeled in Erlang, consisting of the following key components:

1. **Factory:** Continuously generates packages and assigns them randomly to conveyor belts by sending the message `{pass, {package, PackId}}`.

2. **Belts:** Responsible for receiving packages from the factory and forwarding them to trucks, which are selected randomly. The message sent includes the package and a reference to the belt itself, as the process does not proceed until it receives a control message (`Ctrl`). This control message indicates whether the package has been accepted or not. 
   - **If the message is `ok` (indicating the previous package has been successfully loaded onto the truck):** The belt waits for a new package from the factory and repeats the process.
   - **Otherwise, if the package is returned (indicating it could not be loaded):** The belt redistributes the package by attempting to assign it to a different truck.

3. **Trucks:** Load packages from the conveyor belts, ensuring they manage their capacity. Once a truck reaches its maximum capacity of six packages, it dispatches them and notifies the belt to redistribute the current package if necessary.

### Compliance with Requirements

**Concurrency:**  
The conveyor belts (three processes), trucks (five processes), and the factory are independent processes that interact concurrently through message passing.

**Deadlock-Free and Progress Guarantee:**  
There are no deadlocks in the system. Conveyor belts and trucks operate in infinite loops, ensuring continuous processing of packages by redistributing them if a truck is full. In other words, all possible scenarios are considered and managed effectively.

**Message Passing:**  
Coordination and synchronization are handled exclusively through message passing, with distinct message types tailored to each specific management case.

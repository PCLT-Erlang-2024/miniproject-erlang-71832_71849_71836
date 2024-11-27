### Functional Application: Package Size  

In `task2`, packages have an additional attribute, size (`Size`), which varies randomly between 1 and 4. This change requires all functions to account for and transmit this extra attribute. Additionally, several modifications have been implemented in the truck functionality. The truck’s maximum capacity is now measured in terms of total available space (10 units). There are three distinct behavioral cases:  

1. Package exceeds the truck's remaining space: The package is rejected and redistributed.  
2. Package exactly fills the truck's capacity: The truck dispatches its load.  
3. Package fits in the truck: The package is load and the truck's capacity is updated

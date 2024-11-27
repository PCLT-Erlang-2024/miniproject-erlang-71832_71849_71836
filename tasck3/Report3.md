### Expansion of Functionality: Non-Instantaneous Truck Replacement  

When a truck is full, in addition to dispatching its load, it pauses the associated conveyor belt (`Belt`) from which the package was sent. This blockage is implemented by simply calling `timer:sleep` before sending the confirmation message to the belt. Since the belt waits to receive this confirmation before proceeding, it remains blocked and does not distribute further packages. Additionally, there is no mechanism for another truck to restore the belt, as no new distribution begins until the previous one is completed.

# Problem Definition

We've built a web platform that powers our pharmacy and one of its core services is the Task system. A task is a single unit of work for an employee. There are many types of tasks, such as responding to a patient message or updating a prescription.

An employee can get the next task they should work on, with the following requirements:

* Each employee has a role that determines the types of tasks they can complete. For example, a pharmacist can respond to a message or update a prescription, but a customer service representative can only respond to a patient message.

* Each type of task has an expected completion time. For example, the expected completion time for responding to a patient message could be 30 minutes, which means we want to complete that type of task within 30 minutes of being created. An employee should get the task that is closest to exceeding its completion time.

Given an employee and a collection of tasks, your challenge is to write the code for a method that returns the correct task for that employee. By the end, you should have running code that you can show meets the requirements with functional examples or tests.


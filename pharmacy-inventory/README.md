# Pharmacy Inventory

## Introduction

Your goal is to build an API that enables pharmacy patients to place orders from an existing inventory of products. We've provided a list of Medications, inventory, and upcoming orders of inventory we expect to come in in the future all as JSON files enclosed.

## Requirements

1. An API endpoint allowing users to see available products
2. An API endpoint allowing users to get the date their order may be able to be fulfilled on
  - Taking into account the upcoming inventory orders we expect to receive
  - All orders placed before 4 PM may be fulfilled on the same day. Otherwise, there's an additional one-day delay on fulfillment
3. An API endpoint that actually places an order

### Tips

- You're welcome to use StackOverflow, Google, or any other resources at your disposal-- including your interviewer!
- You may use cURL, Postman, unit tests, or just about anything else to demonstrate your solution
- Focus on the business logic at hand here
- Persistence in e.g. a database is not necessary and may make it difficult to finish in the allotted time. Try to focus on the business logic
- Run the script in this file to generate the last JSON file! We made it dynamic so the dates make sense

## Endpoints

You will be responsible for building the following API endpoints:

### Get available Medications

This endpoint should respond with a list of available Medications, including their id,
name and price.

#### Response

The response should be a JSON-formatted array of Medications.

### Get next available date for an order

#### Request

The body of the request will contain a JSON array of Medication IDs and desired
quantities. For example:

```json
[
  {
    "medication_id": 1,
    "quantity": 10
  },
  {
    "medication_id": 3,
    "quantity": 20
  }
]
```

#### Response

The response should return a date that indicates the earliest date that we may fulfill that order.

### Placing an order

#### Request

The request will contain a JSON array of Medication IDs and desired quantities (the same format as checking for the next available date above) and the date the user would like to receive them. For example:


```json
{
  "date": "2020-01-07",
  "Medications": [
    {
      "medication_id": 1,
      "quantity": 10
    },
    {
      "medication_id": 3,
      "quantity": 20
    }
  ]
}
```

#### Response

If we can fulfill the order, the response should indicate success.

If we cannot fulfill the order, we should return a human-readable error message.

## Input Data

Medications, current inventory, and upcoming inventory are provided as arrays of JSON objects. The schema for each type of object are as follows:

```typescript
class Medicationcation {
  id: number;
  name: string;
  price: number;
}

class Inventory {
  medication_id: number;
  quantity: number;
}

class InventoryOrder {
  medication_id: number;
  quantity: number;
  date: string;
}
```

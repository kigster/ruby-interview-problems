# Notability Interview

Implement a rate limiter that allows N requests per time window per user.
The interface should be something like isAllowed(userId: string): boolean.
if number of req reaches N during 10 minutes period we return false until
10 minute period resets, then we start returning true, until we hit N again
or end of 10 minute period.

> [!CAUTION] 
> Took me over 45 minutes to do this right mostly due to typos.


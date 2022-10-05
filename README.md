# Elixir Code Security: Make it a priority using your CI

More and more security is becoming an essential concern for companies as we're seeing a rise in attacks and leaks. As a team using Elixir how can we ensure that each release does not increase risk? In this post, we're going to use multiple tools from the Elixir ecosystem that will increase our confidence in an automated easy way using Semaphore CI.

## Familiar story

When you want to move fast, people tend to ignore certain good practices that, in reality, can actually end up saving time and your company long term. Vulnerabilities can come from multiple fronts like SQL injection in your code or a faulty dependency.

We can mitigate stories like this by properly checking your dependencies and your Elixir code.

## Starting with the basic

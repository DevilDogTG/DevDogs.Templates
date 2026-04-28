namespace GraphQLApi.GraphQL;

[QueryType]
public class Query
{
    public string Hello(string name = "World") => $"Hello, {name}!";
}

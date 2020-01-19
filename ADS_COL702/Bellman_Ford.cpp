#include <bits/stdc++.h>
using namespace std ;

#define MAX 10005

int n, m ;
long long dist[MAX] ;
bool neg_cycle ;
vector< pair<int, long long> > adj[MAX] ; // node and edge weight


void bellman_ford(int s)
{
    dist[s] = 0 ;

    for(int r=1; r<=n-1; r++)   // Repeat all edge relaxation (|V| - 1) times
    {
        for(int i=0; i<n; i++)
        {
            for(int j=0; j<adj[i].size(); j++)
            {
                int nbr = adj[i][j].first ;
                long long weight = adj[i][j].second ;

                if(dist[i] != INT_MAX && dist[i] + weight < dist[nbr])
                    dist[nbr] = dist[i] + weight ;
            }
        }
    }

    for(int i=0; i<n; i++)
    {
        for(int j=0; j<adj[i].size(); j++)
        {
            int nbr = adj[i][j].first ;
            long long weight = adj[i][j].second ;
            if(dist[i] != INT_MAX && dist[i] + weight < dist[nbr])
            {
                neg_cycle = true ;
                return ;
            }
        }
    }
}


int main()
{
    cout<< "Enter number of nodes : " ;
    cin>>n ;
    cout<< "\nEnter number of edges : " ;
    cin>>m ;

    neg_cycle = false ;
    for(int i=0; i<n; i++)
    {
        dist[i] = LLONG_MAX ;
    }

    cout<< "\nNow input edges \"u v c\" format, 1-based index :\n" ;
    for(int u,v,c,i=0; i<m; i++)
    {
        cin>> u >> v >> c ;
        u--;    v--;
        adj[u].push_back( {v, c} ) ;

        // If undirected, then uncomment the next line
        // adj[v].push_back( {u, c} ) ;
    }

    int s ;
    cout<< "\nEnter source : " ;
    cin>> s ;

    bellman_ford(s-1) ; // 0-based index

    if(neg_cycle)
        cout<<"There's a Negative Cycle reachable from source.\n" ;
    else
    {
        cout<< "\nSource " << s << " to\n" ;
        for(int i=0; i<n; i++)
        {
            cout<< i+1 << " := " << dist[i] <<endl ;
        }
    }

    return 0 ;
}
/*
Sample Input :
5 8
1 2 -1
1 3 4
2 3 3
2 4 2
2 5 2
4 2 1
4 3 5
5 4 -3
1

Sample Output :
Source 1 to
1 := 0
2 := -1
3 := 2
4 := -2
5 := 1
*/
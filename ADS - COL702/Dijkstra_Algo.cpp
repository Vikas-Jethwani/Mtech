#include <bits/stdc++.h>
using namespace std ;

#define MAX 100005

int n, m ;
long long dist[MAX] ;
bool visited[MAX] ;
vector< pair<int, long long> > adj[MAX] ; // node and edge weight
priority_queue< pair<long long, int> > pq ; // Cost and node


void dijkstra(int s)
{
    pq.push( {0, s} ) ;
    dist[s] = 0;    visited[s] = true ;

    while(!pq.empty())
    {
        long long path_cost = -1*pq.top().first ; // Negative handle
        int node = pq.top().second ;
        pq.pop() ;

        visited[node] = true ;
        for(int i=0; i<adj[node].size(); i++)
        {
            int nbr = adj[node][i].first ;
            long long weight = adj[node][i].second ;

            if(dist[nbr] > path_cost + weight && visited[nbr] == false)
            {
                dist[nbr] = path_cost + weight ;
                pq.push( {-1*dist[nbr], nbr} ) ;    // Insert negative to maintain min-heap
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

    for(int i=0; i<n; i++)
    {
        dist[i] = LLONG_MAX;
        visited[i] = false;
    }
    while(!pq.empty())
        pq.pop();

    cout<< "\nNow input edges \"u v c\" format, 1-based index :\n" ;
    for(int u,v,c,i=0; i<m; i++)
    {
        cin>> u >> v >> c;
        u--;    v--;
        adj[u].push_back( {v, c} );

        // If undirected
        // adj[v].push_back( {u,c} );
    }

    int s;
    cout<< "\nEnter source : ";
    cin>> s;
    s--;    // 0-based index

    dijkstra(s);

    cout<< "\nSource " << s << " to\n";
    for(int i=0; i<n; i++)
    {
        cout<< i+1 << " := " << dist[i] <<endl;
    }

    return 0;
}

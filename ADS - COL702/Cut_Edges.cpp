#include <bits/stdc++.h>
using namespace std ;

#define MAX 100005

int n, m ;
bool visited[MAX] ;
int s[MAX], dbe[MAX], par[MAX];
vector <int> adj[MAX] ;
vector <pair <int, int> > cut_edges;
int timer=0;

void find_Bridges(int node)
{
    visited[node] = true;
    s[node] = ++timer;

    for(int i=0; i<adj[node].size(); i++)
    {
        int nbr = adj[node][i];
        if(nbr == par[node])
            continue;

        if(visited[nbr] == false)
        {
            par[nbr] = node;
            find_Bridges(nbr);
        }
        else
            dbe[node] = min(dbe[node], s[nbr]);

        dbe[node] = min(dbe[node], dbe[nbr]);
    }

    if(dbe[node] == s[node])
        dbe[node] = INT_MAX;

    if(dbe[node] == INT_MAX && par[node] != -1)
        cut_edges.push_back( {node+1, par[node]+1} );
}


int main()
{
    cout<< "Enter number of nodes : " ;
    cin>>n ;
    cout<< "\nEnter number of edges : " ;
    cin>>m ;

    for(int i=0; i<n; i++)
    {
        visited[i] = false;
        s[i] = par[i] = -1;
        dbe[i] = INT_MAX;
    }

    cout<< "\nNow input edges \"u v\" format, 1-based index :\n" ;
    for(int u,v,i=0; i<m; i++)
    {
        cin>> u >> v ;
        u--;    v--;
        adj[u].push_back( v );
        adj[v].push_back( u );
    }

    find_Bridges(0);

    cout<< "\nNumber of bridges " << cut_edges.size() << "\nCut Edges between :\n";
    for(int i=0; i<cut_edges.size(); i++)
    {
        cout<< cut_edges[i].first << " & " << cut_edges[i].second <<endl;
    }

    return 0;
}

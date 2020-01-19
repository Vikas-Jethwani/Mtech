#include <bits/stdc++.h>
using namespace std ;

#define MAX 10005

int n, m ;
vector<int> out_list[MAX] ;
vector<int> in_list[MAX] ; // For G-reverse
bool visited[MAX] ;
int finish_time[2*MAX] ; // Stores at what time which vertex finished
int timer ;
vector<int> sorted_fv ;
vector<int> scc_list ;


void clear( void )
{
    timer = 0 ; // 0-based => 0 to 2*n-1
    sorted_fv.clear() ;
    for(int i=0; i<n; i++)
    {
        out_list[i].clear() ;
        in_list[i].clear() ;
        visited[i] = false;
    }
    for(int i=0; i<2*n; i++)
        finish_time[i] = -1 ;
}

void dfs_fr( int s )
{
    visited[s] = true ;
    for(int i=0; i<out_list[s].size(); i++)
    {
        if(visited[out_list[s][i]] == false)
        {
            timer++ ;
            dfs_fr( out_list[s][i] ) ;
        }
    }
    
    timer++ ;
    finish_time[timer] = s ;
}

void dfs_br( int s )
{
    visited[s] = true ;
    scc_list.push_back(s) ;

    for(int i=0; i<in_list[s].size(); i++)
    {
        if(visited[in_list[s][i]] == false)
        {
            dfs_br( in_list[s][i] ) ;
        }
    }
}

void review( void )
{
    for(int i=2*n-1; i>=0; i--)
    {
        if(finish_time[i] != -1)
        {
            sorted_fv.push_back(finish_time[i]) ;
        }
    }

    for(int i=0; i<n; i++)
        visited[i] = false ;
}

void tarjan( void )
{
    for(int i=0; i<n; i++)
    {
        if(visited[i] == false)
            dfs_fr( i ) ;
    }

    review() ;

    cout<< "Connected Components : \n" ;
    for(int i=0; i<n; i++)
    {
        if(visited[i] == false)
        {
            scc_list.clear() ;
            dfs_br( i ) ;

            for(int j=0; j<scc_list.size(); j++)
                cout<< scc_list[j]+1 <<" " ;
            cout<<endl ;
        }
    }
}


int main()
{
    cout<< "Enter number of nodes : " ;
    cin>>n ;
    cout<< "\nEnter number of edges : " ;
    cin>>m ;

    cout<< "\nNow input edges \"u v\" format, 1-based index :\n" ;
    for(int u, v, i=0; i<m; i++)
    {
        cin>>u>>v ;
        u-- ;  v-- ;
        out_list[u].push_back(v) ;
        in_list[v].push_back(u) ;
    }

    tarjan() ;

    return 0;
}

#include <bits/stdc++.h>
using namespace std;

struct event
{
    int idx ;
    int first ;
    int second ;
};

bool myComp(const event &e1, const event &e2)
{
    if(e1.second < e2.second)
        return true ;
    else if(e1.second > e2.second)
        return false ;
    else
        return e1.first < e1.second ;
}

void maxActivities(event e[], int n)
{
    // Sort based on 2nd value
    sort(e, e+n, myComp) ;

    // Greedy Approach
    int ans=0, curr_mx=-1 ;
    for(int i=0; i<n; i++)
    {
        if(e[i].first >= curr_mx)
        {
            cout<< e[i].idx << " " ;
            curr_mx = e[i].second ;
            ans++ ;
        }
    }
}


int main()
{
    int n ;
    cin>>n ;

    event events[n] ;
    for(int i=0; i<n; i++)
    {
        events[i].idx = i+1 ;
        cin>>events[i].first ;
    }
    for(int i=0; i<n; i++)
        cin>>events[i].second ;

    cout<< "Activities in order :\n" ;
    maxActivities(events, n) ;

    return 0 ;
}

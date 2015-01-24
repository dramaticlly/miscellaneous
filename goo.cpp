#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>

using namespace std;


int main (int argc, char* argv[])
{
  ifstream myfile;
//  ofstream outfile;
  myfile.open (argv[1]);
  if(myfile.is_open())
{
        int numcase;
        myfile >>numcase;
//        cout <<numcase<<" case"<<endl;
        for (int i = 1; i<=numcase; i++)
        {
                int hit=0;
                int ans;
                int row1;
                int row2;
                vector <int> mylist1(16);
                vector <int> mylist2(16);
                mylist1.clear();
                mylist2.clear();
                myfile >> row1;
//                cout <<row1<<endl;
                for (int j = 0; j<16; j++)
                {
                        int q;
                        myfile>>q;
                        mylist1[j]=q;
//                        if(j%4==0)
//                          cout<<endl;
//                        cout <<q<<", ";
                }
//cout<<endl;
                myfile >> row2;
//                cout <<row2<<endl;
                for (int k = 0; k<16; k++)
                {
                        int q;
                        myfile>>q;
                        mylist2[k]=q;
//                        if(k%4==0)
//                          cout<<endl;
//                        cout <<q<<", ";
                }
//cout<<endl;

//cout<<"come for compare\n";
                for (int a = 4*(row1-1); a<=(4*row1-1); a++)
                {
//                        cout <<"a: "<<a<<endl;
                        for (int b = 4*(row2-1); b<=(4*row2-1); b++)
                        {
//                                cout <<"b: "<<b<<endl;
                                if(mylist1[a] == mylist2[b])
                                        {
                                                hit++;
                                                ans = mylist2[b];
//                                                cout<<"ans: "<<ans<<endl;
                                        }
//                                else
//                                {
//                                cout<<"a: "<<mylist1[a]<<"b: "<<mylist2[b]<<endl;
//                                }
                        }
                        mylist1[a]=-1;
                }

                if(hit == 0)
                        cout <<"Case #"<<i<<": Volunteer cheated!\n";
                else if(hit == 1)
                        cout <<"Case #"<<i<<": "<<ans<<endl;
                else
                        cout <<"Case #"<<i<<": Bad magician!\n";//hit: "<<hit<<endl;
//                        cout <<"Case #"<<i<<": Bad magician!\nhit: "<<hit<<endl;
        }
}
else
        cout << "Unable to read from file"<<endl;

  myfile.close();

return 0;
}



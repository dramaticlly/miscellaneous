// template created by: Hongyue Zhang /hyz/
// template created at: 2015-1-23 21:12:51
// temlpate used for:   google code jam 
// ALL RIGHTS RESERVED //

#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>

using namespace std;


int main (int argc, char* argv[])
{
/*intput file opened with argument*/
  ifstream myfile;
  myfile.open (argv[1]);

/*loop through the test case*/
  if(myfile.is_open())
{
        int hit;
        int numcase;
        myfile >>numcase;

        for (int i = 1; i<=numcase; i++)
        {


/* output field */
                if(hit == 0)
                        cout <<"Case #"<<i<<": "<<endl;
                else if(hit == 1)
                        cout <<"Case #"<<i<<": "<<endl;
                else
                        cout <<"Case #"<<i<<": "<<endl;
        }
}
else
        cout << "Unable to read from file"<<endl;
  myfile.close();
return 0;
}



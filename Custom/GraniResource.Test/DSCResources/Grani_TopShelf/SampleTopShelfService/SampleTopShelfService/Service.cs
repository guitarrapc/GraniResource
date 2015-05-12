using System;
using System.Collections.Generic;
using System.Diagnostics.Eventing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SampleTopShelfService
{
    internal class Service
    {
        public string ServiceName { get; private set; }

        public Service(string serviceName)
        {
            this.ServiceName = serviceName;
        }

        public void Start()
        {
            Console.WriteLine("Running Service");
        }

        public void Stop()
        {
            Console.WriteLine("Stopping Service");
        }
    }
}
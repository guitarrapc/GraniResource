using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Topshelf;

namespace SampleTopShelfService
{
    class Program
    {
        private static readonly string _serviceName = "SampleTopShelfService";
        private static readonly string _displayName = "SampleTopShelfService";
        private static readonly string _description = "SampleTopShelfService Description";

        static void Main(string[] args) => HostFactory.Run(x =>
        {
            x.EnableShutdown();

            // Reference to Logic Class
            x.Service<Service>(s =>
            {
                s.ConstructUsing(name => new Service(_serviceName));
                s.WhenStarted(sc => sc.Start());
                s.WhenStopped(sc => sc.Stop());
            });

            // Service Start mode
            x.StartAutomaticallyDelayed();

            // Service RunAs
            x.RunAsLocalSystem();

            // Service information
            x.SetServiceName(_serviceName);
            x.SetDisplayName(_displayName);
            x.SetDescription(_description);
        });
    }
}

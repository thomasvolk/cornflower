# cornflower manual

This document is a brief overview of the cornflower funtions.

## command line parameters

cornflower has the following commandline parameters:

```
Usage: cornflower [options] inputfile
    -v, --version                    show version
    -h, --help                       print help
    -o, --output FILENAME            output filename
    -t, --tags TAGS                  comma separated tag list to include
    -e, --tags-exclude TAGS          comma separated tag list to exlude
```

If -o is not given, the result will be printed to standard out. 
With -t parameter the model can be filtered for a given tag list (comma seperated).
This means, that all nodes will be included, which have at least one tag in the given list.
The -e paramter works the same as -t but it excludes all nodes with the given tags.

## the language

The language is a subset of ruby.

## header

Every cornflower model must be embedded in the Cornflower Model:

    Cornflower::Model.new do
      # ...
    end

## nodes

Nodes can be hirarchical:

    network02 do
      shopsystem()
      cms()
    end

They can have attributes:

* style: node style
* shape: shape of the node
* tags: a list of tags

see planUML documentation

    CloudProvider(
      :style => "aliceblue;line:blue;line.dotted;text:blue",
      :shape => :agent,
      :tags => [:network, :cloud]
    )

## relations

A relastion can be set between two nodes:

    webserver() >> appserver()
    database() << appserver()

They can have a description:

    OrderQueue() <<  Kubernetes().WarehouseService | "pull order"

They can have attributes:

* style: line style
* shape: shape of the line

see planUML documentation

    OrderQueue() <<  Kubernetes().WarehouseService | "pull order" < {:style => "line:red;line.bold;text:red", :shape => '..>'}

## tagging

You  can set tags for every node:

    loadbalancer(:tags => [:cms, :shop])

The value must be a list of atoms. 

Here is an exaple with uses different tags:

see: [tagging.cf](../example/tagging.cf)

```
Cornflower::Model.new do
  network01(:tags => [:network]) do
    loadbalancer(:tags => [:cms, :shop])
    webserver01(:tags => [:cms, :shop])
    webserver02(:tags => [:cms, :shop])

    loadbalancer() >> webserver01()
    loadbalancer() >> webserver02()
  end
  network02(:tags => [:network]) do
    shopsystem(:tags => [:shop])
    cms(:tags => [:cms])
  end

  network01().webserver01() >> network02().shopsystem()
  network01().webserver02() >> network02().shopsystem()
  network01().webserver01() >> network02().cms()
  network01().webserver02() >> network02().cms()
end
```

If you filter for the tag *cms* you will get the following result:

    cornflower -t cms tagging.cf

```
@startuml

node loadbalancer
node webserver01
node webserver02
node cms
loadbalancer --> webserver01
loadbalancer --> webserver02
webserver01 --> cms
webserver02 --> cms

@enduml
```

If you exclude the network *cms* you will get the following result:

    cornflower -e network tagging.cf

```
@startuml

node loadbalancer
node webserver01
node webserver02
node shopsystem
node cms
loadbalancer --> webserver01
loadbalancer --> webserver02
webserver01 --> shopsystem
webserver02 --> shopsystem
webserver01 --> cms
webserver02 --> cms

@enduml
```

## multiple files

With the *load* command you can combine multiple source files to one model.

see: [cluster.cf](../example/cluster.cf)

```
model = Cornflower::Model.new do
  load('parts/cluster01.cf')
  load('parts/cluster02.cf')
  load('parts/cluster03.cf')
  load('parts/connections.cf')
end
```

## defaults

There can be default values be defined for shape and style for nodes and lines.   

see: [cluster-defaults.cf](../example/cluster-defaults.cf)

```
model = Cornflower::Model.new(
  :default_line_style => "blue",
  :default_line_shape => "-[thickness=2]->",
  :default_node_shape => "agent",
  :default_node_style => "aliceblue"
) {
  load('parts/cluster01.cf')
  load('parts/cluster02.cf')
  load('parts/cluster03.cf')
  load('parts/connections.cf')
}

```
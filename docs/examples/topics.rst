Topics : Receiving messages based on a pattern
==============================================

Topics are another exchange type. It allows message routing depending on a
pattern, to route a message for multiple criteria.

We're going to use a topic exchange in our logging system. We'll start off
with a working assumption that the routing keys of logs will have two
words: "<facility>.<severity>".

Publisher
---------

The publisher prepares the exchange and publish messages using a
routing_key which will be matched by later filters

 .. code-block:: python

    await channel.exchange('topic_logs', 'topic')

    await await channel.publish(message, exchange_name=exchange_name, routing_key='anonymous.info')
    await await channel.publish(message, exchange_name=exchange_name, routing_key='kern.critical')




Consumer
--------

The consumer selects the combination of 'facility'/'severity' it wants to subscribe to:

 .. code-block:: python

    for binding_key in ("*.critical", "nginx.*"):
        await channel.queue_bind(
            exchange_name='topic_logs',
            queue_name=queue_name,
            routing_key=binding_key
        )

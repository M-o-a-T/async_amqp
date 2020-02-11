RPC: Remote procedure call implementation
=========================================


This tutorial will try to implement the RPC as in the RabbitMQ's tutorial.

The API will probably look like:

 .. code-block:: python

     fibonacci_rpc = FibonacciRpcClient()
     result = await fibonacci_rpc.call(4)
     print("fib(4) is %r" % result)


Client
------

In this case it's no longer a producer but a client: we will send a message
to a queue and wait for a response in another. For that purpose, we publish
a message to the `rpc_queue` and add a `reply_to` property to let the
server know where to respond.

 .. code-block:: python

    result = await channel.queue_declare(exclusive=True)
    callback_queue = result['queue']

    channel.basic_publish(
        exchange='',
        routing_key='rpc_queue',
        properties={
            'reply_to': callback_queue,
        },
        body=request,
    )


Note: the client uses a `waiter` (a ``anyio.abc.Event``) which will be set when
receiving a response from the previously sent message.


Server
------

When unqueuing a message, the server will publish a response directly in
the callback. The `correlation_id` is used to let the client know it's a
response from this request.

 .. code-block:: python

    async def on_request(channel, body, envelope, properties):
        n = int(body)

        print(" [.] fib(%s)" % n)
        response = fib(n)

        await channel.basic_publish(
            payload=str(response),
            exchange_name='',
            routing_key=properties.reply_to,
            properties={
                'correlation_id': properties.correlation_id,
            },
        )

        await channel.basic_client_ack(delivery_tag=envelope.delivery_tag)

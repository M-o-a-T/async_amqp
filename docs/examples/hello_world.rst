"Hello World!" : The simplest thing that does something
=======================================================

Sending
-------

Our first script to send a single message to the queue.

Creating a new connection:

 .. code-block:: python

    import trio
    import trio_amqp

    async def connect():
        protocol = await trio_amqp.connect()
        channel = await protocol.channel()

    trio.run(connect)


This first scripts shows how to create a new connection to the `AMQP` broker.

Now we have to declare a new queue to receive our messages:

 .. code-block:: python

    await channel.queue_declare(queue_name='hello')

We're now ready to publish message on to this queue:

 .. code-block:: python

    await channel.basic_publish(
        payload='Hello World!',
        exchange_name='',
        routing_key='hello'
    )


We can now close the connection to rabbit:

 .. code-block:: python

    # close using the `AMQP` protocol
    await protocol.close()
    # ensure the socket is closed.
    transport.close()

You can see the full example in the file `example/send.py`.

Receiving
---------

We now want to unqueue the message in the consumer side.

We have to ensure the queue is created. Queue declaration is indempotant.

 .. code-block:: python

    await channel.queue_declare(queue_name='hello')


To consume a message, the library calls a callback (which **MUST** be a coroutine):

 .. code-block:: python

    async def callback(channel, body, envelope, properties):
        print(body)

    await channel.basic_consume(callback, queue_name='hello', no_ack=True)


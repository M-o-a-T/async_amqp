Work Queues : Distributing tasks among workers
==============================================

The main purpose of this part of the tutorial is to `ack` a message in
RabbitMQ only when it's really processed by a worker.

new_task
--------

This publisher creates a queue with the `durable` flag and publish a
message with the property `persistent`.

 .. code-block:: python

    await channel.queue('task_queue', durable=True)

    await channel.basic_publish(
        payload=message,
        exchange_name='',
        routing_key='task_queue',
        properties={
            'delivery_mode': 2,
        },
    )


worker
------

The purpose of this worker is to simulate a resource consuming execution
which delays the processing of the other messages.

The worker declares the queue with the exact same argument of the `new_task` producer.

 .. code-block:: python

    await channel.queue('task_queue', durable=True)


Then, the worker configure the `QOS`: it specifies how the worker unqueues message.

 .. code-block:: python

    await channel.basic_qos(prefetch_count=1, prefetch_size=0, connection_global=False)


Finaly we have to create a callback that will `ack` the message to mark it as `processed`.

Note: the code in the callback calls `anyio.sleep` to simulate a task that
takes time.

 .. code-block:: python

    async def callback(channel, body, envelope, properties):
        print(" [x] Received %r" % body)
        await anyio.sleep(body.count(b'.'))
        print(" [x] Done")
        await channel.basic_client_ack(delivery_tag=envelope.delivery_tag)

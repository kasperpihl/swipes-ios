#Swipes URL scheme description

We've added a way to interract with swipes via URLs. The easiest way to test it is to enter URL in Mobile Safari

The scheme is calles swipes which means that all URLs must start with `swipes://`. Then follows the target, command and params. In general Swipes URL looks like: `swipes://todo/add?title=New%21TODO&priority=1`. Here `todo` is the target, `add` is command (supported commands depend on the target), and the rest after the `?` are params delimited by `&`. For parameters we apply the same escape rules as with HTTP URL parameters.

Please note that this is one directional connection. There is no way for you to get result about whether or not the command execution finished successfully

##Targets

Here is a list of available targets

target | action
------ | -------------
todo   | add/update/delete a todo
tag    | add/update/delete a tag
 

###todo

Todo is used to add update or delete a ToDo from Swipes.

####Adding ToDo

The command is `add` and it supports the following parameters:

parameter | description
----------| -------------
title     | Set the ToDo title. This is the only mandatory parameter. If title is not set or there is already a ToDo with that title, the URL is ignored
priority  | Set to `y` or `1` to make the ToDo priority. Default is `no`
notes     | Notes of the ToDo. Default is no notes
schedule  | The schedule of ToDo set to the given number of seconds from the first instant of 1 January 1970, GMT. There is a special value `now` (ex: `schedule=now`) that adds current date and time as a schedule. Default is to set schedule to undefined
tagN      | An array of tags to add to the ToDo. If any tag does not exist, it will be created. N is the number of tag starting from 1. For example to specify three tags you add them like this: `tag1=first%20tag&tag2=second&tag3=third`. Default is ToDo does not have tags attached.

#####Examples

`swipes://todo/add?title=Buy%20coffee&schedule=now` - Creates a ToDo with title `Buy coffee` and schedule it for current date and time.

`swipes://todo/add?title=Buy%20coffee&tag1=shopping&tag2=development&priority=1&notes=need%20coffee%0ato%20develop&schedule=1406636343`- Creates a ToDo with title `Buy coffee`, Tags `shopping` and `development`, set it to ne a priority ToDo, notes are `need coffee<new line>to develop`, schedule it to a specific time.

####Updating ToDo

The command is `update`. Note that in order to 'clear' a field you need to specify it as an empty parameter. For example: `swipes://todo/update?oldtitle=beer&notes=` will clear the notes of the ToDo with title `beer`. Parameters which are not specified will be left unchanged. The command supports the following params:

parameter | description
----------| -------------
oldtitle  | This is the title used to select a ToDo to update. This is the only mandatory parameter. 
title     | Updates the title.
priority  | Set to `y` or `1` to make the ToDo priority.
notes     | Notes of the ToDo.
schedule  | The schedule of ToDo set to the given number of seconds from the first instant of 1 January 1970, GMT. There is a special value `now` (ex: `schedule=now`) that adds current date and time as a schedule.
tagN      | An array of tags to add to the ToDo. If any tag does not exist, it will be created. N is the number of tag starting from 1. For example to specify three tags you add them like this: `tag1=first%20tag&tag2=second&tag3=third`.

#####Examples

`swipes://todo/update?oldtitle=Buy%20coffee&title=Buy%20beer&notes=` - Updates a ToDo with title `Buy coffee`, changing title to `Buy beer` and clearing notes.

####Deleting ToDo

The command is `delete`. It removes a ToDo from Swipes and has a single parameter:

parameter | description
----------| -------------
title     | The ToDo title to be deleted. This is the only parameter and is mandatory.

#####Examples

`swipes://todo/delete?title=Buy%20coffee` - Deletes a ToDo with title `Buy coffee`.

###tag

Tag is used to add update or delete a tag from Swipes.

####Adding tag

The command is `add` and it supports the following parameters:

parameter | description
----------| -------------
title     | Set the tag title. This is the only parameter and is mandatory. If title is not set or there is already a tag with that title, the URL is ignored

#####Examples

`swipes://tag/add?title=Shopping%20list` - Creates a tag with title `Shopping list`.

####Updating tag

The command is `update` and it supports the following parameters:

parameter | description
----------| -------------
oldtitle  | This is the title used to select a tag to update. This is a mandatory parameter. 
title     | Updates the title. This is a mandatory parameter.

#####Examples

`swipes://tag/update?oldtitle=Shopping%20list&title=Wife%20requests` - Updates a tag with title `Shopping list`, changing title to `Wife requests`.

####Deleting tag

The command is `delete`. It removes a tag from Swipes and has a single parameter:

parameter | description
----------| -------------
title     | The tag title to be deleted. This is the only parameter and is mandatory.

#####Examples

`swipes://tag/delete?title=Shopping%20list` - Deletes a tag with title `Shopping list`.


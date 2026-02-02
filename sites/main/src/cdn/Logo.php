<?php

use FastRaven\Components\Http\Request;
use FastRaven\Components\Http\Response;

return function(Request $request): Response {
    return Response::file(true, "logo.png");
};
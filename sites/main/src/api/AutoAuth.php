<?php

use FastRaven\Components\Http\Request;
use FastRaven\Components\Http\Response;
use FastRaven\Services\AuthService;
use FastRaven\Types\SanitizeType;

return function(Request $request): Response {
    $check = $request->post("check", SanitizeType::ONLY_ALPHA) === "1234567890";

    if($check === true) {
        AuthService::createAuthorization(1);
        return Response::new(true, 200, "Authorization created.");
    }
    else return Response::new(false, 400, "Invalid data.");
};
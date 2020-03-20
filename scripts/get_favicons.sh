curl -L -o wikipedia.png https://wikipedia.org/favicon.ico

function get_favicon {
    # $1 == hostname
    curl -L -o $1.png https://$1.com/favicon.ico
}

get_favicon facebook
get_favicon google
get_favicon youtube
get_favicon amazon
get_favicon yahoo
get_favicon reddit
get_favicon ebay
get_favicon netflix
get_favicon bing
